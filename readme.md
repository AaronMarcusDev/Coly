# Coly Programming Language 🐦

Coly is a open-source, high-level, compiled stack-oriented programming language.\
 It supports both compilation and interpretation on Windows and Linux. Think of it like a minimalist cousin to Forth or Factor, but with its own flavor.

```c
"Hello, Coly!" puts
```

## 🧪 Core Concepts
Since Coly is stack-based, it operates on a Last-In-First-Out (LIFO) principle. You push values onto the stack and apply operations that consume or manipulate them.

Example:

```c
5 3 + puts
```

This would push 5 and 3 onto the stack, apply +, and then print the result.

## 🧾 Commands
 While there's no formal documentation yet, here are the commands:
 
 | Command | Description |
 | --------| -----------|
 | puts | 	Prints the top value on the stack |
 | + - * / |	Arithmetic operations |
 | dup	| Duplicates the top stack value |
 | drop| 	Removes the top stack value |
 | swap| 	Swaps the top two values |
 | over| 	Copies the second value to the top |

## 📄 Documentation
There is no official documentation for Coly **yet.**

## Learn
The best approach for learning Coly at the moment is by looking at Coly code and projects.\
You can start here!

Language
- [Datatypes](https://github.com/AaronMarcusDev/Coly/blob/main/coly/md/datatypes.md)

Projects using Coly
- [Langlang](https://github.com/AaronMarcusDev/Langlang)

## Contributing
[Pull requests](https://github.com/AaronMarcusDev/Coly/pulls) are welcome, make sure to write a good description.

Please report issues and bugs at the [Issues Page](https://github.com/AaronMarcusDev/Coly/issues).

## License
Coly is licensed under the [MIT license](https://choosealicense.com/licenses/mit/).
