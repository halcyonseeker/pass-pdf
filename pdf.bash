#!/usr/bin/env bash

VERSION=1.0.0
# OUTPUT_FILE=""
# PREAMBLE_FILE=""
declare -a EXCLUDE_REGEXES
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
       multiple time to exclude some passwords from being archived.  Pass -p
       to add some preamble to the PDF, if it's a '-' this will be read from
       stdin instead of a file.
    $PROG
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

pdf_generate_preamble() {
	cat <<-_EOF
.TL
Password Store Backup Created $(date +'%Y-%m-%d %R %Z')
.AU
$(user_real_name)
.CW $(whoami)@$(hostname -f)
.PP
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
			is_password_excluded "$p" || pdf_generate_password_section
		done
	else
		for p in "$@"; do
			is_password_excluded "$p" || pdf_generate_password_section "$p"
			shift
		done
	fi
}

while true; do
	case "$1" in
		help|--help|-h)       cmd_pdf_help ;;
		version|--version|-v) cmd_pdf_version ;;
		# --output|-o)          OUTPUT_FILE="$2"; shift 2 ;;
		# --preamble|-p)        PREAMBLE_FILE="$2"; shift 2 ;;
		--exclude|-x)         EXCLUDE_REGEXES+=("$2"); shift 2 ;;
		*)                    pdf_generate_source "$@"; break ;;
	esac
done
