module parser

import strconv
import lexer { Token, TokenKind }
import ast {
    Program,
    SchemeNode,
    StringNode,
    NumberNode,
    BooleanNode,
    SymbolNode,
    QuotedNode,
    ListNode
}

struct Parser {
mut:
    tokens []Token
    index  usize
}

pub fn parse(tokens []Token) !Program {
    mut the_parser := Parser {
        tokens: tokens
    }

    mut program_body := []SchemeNode{}
    for !the_parser.is_at_end() {
        program_body << the_parser.expr() or {
            return err
        }
    }

    return Program { body: program_body }
}

fn unwrap[T](v ?T) T {
    return v or { panic("none") }
}

fn (mut self Parser) expr() !SchemeNode {
    tok := self.advance()

    match tok.kind {
        .symbol {
            return SymbolNode {
                value: unwrap(tok.value)
            }
        }
        .number_lit {
            return NumberNode {
                value: f32(strconv.atof64(unwrap(tok.value)) or {
                    panic(err)
                })
            }
        }
        .string_lit {
            return StringNode {
                value: unwrap(tok.value)
            }
        }
        .t, .f {
            return BooleanNode {
                value: tok.kind == .t
            }
        }
        .open_paren {
            return self.list()!
        }
        .quote {
            return QuotedNode {
                child: &SchemeNode(self.expr()!)
            }
        }

        else {
            return error("Can't go deeper than that.")
        }
    }
}

fn (mut self Parser) list() !ListNode {
    head := &SchemeNode(self.expr()!)
    mut tail := []SchemeNode{}

    for self.match(.close_paren) == none {
        tail << self.expr()!
    }

    return ListNode {
        head: head,
        tail: tail
    }
}

fn (mut self Parser) match(kind TokenKind) ?&Token {
    if self.is_at_end() {
        return none
    }
    if kind == self.peek().kind {
        return self.advance()
    }
    return none
}

fn (mut self Parser) advance() &Token {
    if !self.is_at_end() {
        self.index++
    }
    return &self.tokens[self.index]
}

fn (self Parser) peek() &Token {
    if self.is_at_end() {
        panic("bad peek.")
    }
    return &self.tokens[self.index]
}

fn (self Parser) is_at_end() bool {
    return self.index >= self.tokens.len
}
