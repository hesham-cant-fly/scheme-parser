module ast

pub struct Program {
pub:
    body []SchemeNode
}

pub struct StringNode implements SchemeNode {
pub:
    value string
}
pub struct NumberNode implements SchemeNode {
pub:
    value f32
}
pub struct BooleanNode implements SchemeNode {
pub:
    value bool
}

pub struct SymbolNode implements SchemeNode {
pub:
    value string
}
pub struct QuotedNode implements SchemeNode {
pub:
    child &SchemeNode
}

pub struct ListNode implements SchemeNode {
pub:
    head &SchemeNode
    tail []SchemeNode
}

pub interface SchemeNode {
    //to_js() !Value
}






