echo "Finds where GCC looks for the include files"
echo "Look for these two things "
echo "#include "..." search starts here:"
echo "#include <...> search starts here:\n"

echo | gcc -E -v -x c - 2>&1
