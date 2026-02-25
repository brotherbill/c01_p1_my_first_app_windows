// Most languages allow import / include / use statements to pull in libraries.
import std.stdio;

void main()
{
	// D language lets you surgically place the import statement, and libit library members needed.
	// Duplicate members are permitted.
	import std.stdio : writeln;

	writeln("Greetings D!");
}
