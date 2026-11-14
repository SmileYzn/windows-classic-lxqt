#!/bin/sh
# Regenera os arquivos Xcursor a partir de png/ e dos *.in (formato do xcursorgen).
# Para extrair de novo das DLLs do Windows XP, use ../../build.sh.
cd "$(dirname "$0")" || exit 1
for f in *.in; do
	xcursorgen -p . "$f" "../cursors/${f%.in}"
done
