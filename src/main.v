module main

import lexer
import parser

fn main() {
    src := "'(1 2 3) ;; \"String :D\" #t #f"
    tokens := lexer.scan(src)
    println(tokens)
    ast := parser.parse(tokens) or { panic(err) }
    println(ast)
}
