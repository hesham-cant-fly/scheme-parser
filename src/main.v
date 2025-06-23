module main

import lexer

fn main() {
    src := "hello world 123 ( ) ' ;; \"String :D\" #t #f"

    println(
        lexer.scan(src)
    )
}
