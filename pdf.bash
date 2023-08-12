#!/usr/bin/env bash

VERSION=1.0.0
OUTPUT_FILE=""
PREAMBLE_FILE=""
declare -a EXCLUDE_REGEXES
declare -a PASSWORDS
PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"

cmd_pdf_help () {
	cat <<-_EOF
Usage:
    $PROGRAM pdf [version,--version,-v]
       Print extension version.
    $PROGRAM pdf [help,--help,-h]
       Print help for the pdf extension.
    $PROGRAM pdf [-o,--output path.pdf] [-x,--exclude regex]
                 [-p,--preamble path.txt] [optional passwords...]
       Save your passwords to a PDF generated with roff.  If no arguments are
       supplied, dump the roff source for all passwords to stdout.  If some
       passwords are supplied on the command line, only save those ones.
       Pass -o to save to a pdf file instead of dumping the source.  Pass -x
       multiple times to exclude some passwords from being archived.  Pass -p
       to add some preamble to the PDF, if it's a '-' this will be read from
       stdin instead of a file.
_EOF
	exit 0
}

cmd_pdf_version () {
	echo "$VERSION"
	exit 0
}

user_real_name() {
	grep "^$(whoami)" /etc/passwd | cut -d ':' -f5 | cut -d ',' -f1
}

insert_user_supplied_preamble() {
	if [ "$PREAMBLE_FILE" = "-" ]; then
		while read -r l; do echo "$l"; done </dev/stdin
	elif [ -n "$PREAMBLE_FILE" ]; then
		cat "$PREAMBLE_FILE"
	fi
}

pdf_generate_preamble() {
	cat <<-_EOF
.TL
Password Store Backup Created $(date +'%Y-%m-%d %R %Z')
.AU
$(user_real_name)
.CW $(whoami)@$(hostname -f)
.PP
$(insert_user_supplied_preamble)
_EOF
}

pdf_generate_password_section() {
	path="$1"
	cat <<-_EOF
.NH
$path
.LP
.CW
Password contents will go here!
.LP
.CW
another line
.LP
.CW
let's see how this fontifies
.LP
.CW
unicode? длорыфвдаршг🩸  nahh bitch of course that would be too easy :(
_EOF
}

is_password_excluded () {
	for re in "${EXCLUDE_REGEXES[@]}"; do
		[[ "$1" =~ $re ]] && return 0
	done
	return 1
}

pdf_generate_source () {
	pdf_generate_preamble
	if [ $# -eq 0 ]; then
		find "$PASSWORD_STORE_DIR" -name '*.gpg' | while read -r p; do
			p="${p#"$PASSWORD_STORE_DIR"/}"
			is_password_excluded "$p" \
				|| pdf_generate_password_section
		done
	else
		for p in "$@"; do
			is_password_excluded "$p" \
				|| pdf_generate_password_section "$p"
			shift
		done
	fi
}

create_pdf_or_dump_source () {
	if [ -n "$OUTPUT_FILE" ]; then
		(pdf_generate_source "$@") \
			| preconv \
			| groff -ms -T pdf > "$OUTPUT_FILE"
	else
		pdf_generate_source "$@"
	fi
}

assert_arg () {
	[ -n "$2" ] || {
		echo "Fatal: Argument '$1' requires an option." 1>&2
		(cmd_pdf_help) 1>&2
		exit 1;
	}
}

while true; do
	case "$1" in
		help|--help|-h)       cmd_pdf_help ;;
		version|--version|-v) cmd_pdf_version ;;
		--output|-o)
			assert_arg "$1" "$2"; OUTPUT_FILE="$2"; shift 2 ;;
		--preamble|-p)
			assert_arg "$1" "$2"; PREAMBLE_FILE="$2"; shift 2 ;;
		--exclude|-x)
			assert_arg "$1" "$2"; EXCLUDE_REGEXES+=("$2"); shift 2 ;;
		*) if [ -n "$1" ]; then
			   PASSWORDS+=("$1"); shift
		   else
			   break
		   fi ;
	esac
done
create_pdf_or_dump_source "${PASSWORDS[@]}"
