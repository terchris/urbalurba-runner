// File: tests/csharp/hello-world.cs
//
// Purpose: A simple C# program to test the GitHub Actions runner.
// This program prints "Hello, World!" and the current date and time.

using System;

class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("Hello, C# World!");
        Console.WriteLine($"Current date and time: {DateTime.Now}");
    }
}