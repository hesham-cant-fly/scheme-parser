module lexer

pub enum TokenKind {
    open_paren  // (
    close_paren // )
    quote       // '

    number_lit
    string_lit
    symbol
    t
    f
}

pub struct Token {
pub:
    kind   TokenKind
    lexem  string
    value  ?string
    index  usize
    line   usize
    column usize
}

struct Lexer {
    source    string
    path      string
mut:
    tokens    []Token = []
    line      usize = 1
    column    usize = 1
    current   usize
    start     usize
    has_error bool
}

pub fn scan(source string) []Token {
    mut the_lexer := Lexer {
        path: "*unknown*"
        source: source
    }

    for !the_lexer.is_at_end() {
        the_lexer.start = the_lexer.current

        the_lexer.scan()
    }

    return the_lexer.tokens
}

fn (mut self Lexer) scan() {
    ch := rune(self.advance())

    match ch {
        `(` { self.add_token(.open_paren, none) }
        `)` { self.add_token(.close_paren, none) }
        `'` { self.add_token(.quote, none) }

        `"` { self.scan_string() }
        `#` { self.scan_reader() }
        `0`...`9` { self.scan_number() }

        `;` { for !self.is_at_end() && self.advance() != u8(`\n`) {  } }

        ` `, `\r`, `\t` {}
        `\n` {
            self.line++
            self.column = 1
        }

        else {
            if is_symbol(ch) {
                self.scan_symbol()
            } else {
                self.report_error("Unexpected token `${ch}`")
            }
        }
    }
}

fn (mut self Lexer) scan_reader() {
    ch := rune(self.advance())

    match ch {
        `t` { self.add_token(.t, none) }
        `f` { self.add_token(.f, none) }

        else {
            self.report_error("Unsupported reader `${ch}`")
        }
    }
}

fn (mut self Lexer) scan_number() {
    for is_numiric(rune(self.peek())) {
        self.advance()
    }

    value := self.source[self.start..self.current]
    self.add_token(.number_lit, value)
}

fn (mut self Lexer) scan_string() {
    for {
        if self.peek() == u8(`"`) {
            self.advance()
            break
        }
        self.advance()
    }

    value := self.source[self.start + 1 .. self.current - 1]
    self.add_token(.string_lit, value)
}

fn (mut self Lexer) scan_symbol() {
    for {
        ch := rune(self.peek())
        if is_symbol(ch) || is_numiric(ch) {
            self.advance()
            continue
        }
        break
    }

    value := self.source[self.start .. self.current]
    self.add_token(.symbol, value)
}

fn (self Lexer) is_at_end() bool {
    return self.current >= self.source.len
}

fn (mut self Lexer) advance() u8 {
    if self.is_at_end() {
        return 0
    }
    self.current++
    self.column++
    return self.source[self.current - 1]
}

fn (self Lexer) peek() u8 {
    if self.is_at_end() {
        return 0
    }
    return self.source[self.current]
}

fn (mut self Lexer) match(ch u8) ?u8 {
    if self.peek() == ch {
        return self.advance()
    }
    return none
}

fn (mut self Lexer) add_token(kind TokenKind, value ?string) {
    self.tokens << Token {
        kind: kind,
        value: value,
        index: self.start,
        line: self.line,
        column: self.column,
        lexem: self.source[self.start..self.current]
    }
}

fn (self Lexer) report_error(msg string) {
    println("${self.path}:${self.line}:${self.column}: error: ${msg}")
}

// Hello-World!$%&*+-./:<=>?^_~123456789
fn is_symbol(ch rune) bool {
    return match ch {
        `a`...`z`,
        `A`...`Z`,
        `!`, `$`, `%`,
        `&`, `*`, `+`,
        `-`, `.`, `/`,
        `:`, `<`, `=`,
        `>`, `?`, `^`,
        `_`, `~`
        { true }
        else { false }
    }
}

fn is_numiric(ch rune) bool {
    return match ch {
        `0`...`9` { true }
        else { false }
    }
}

