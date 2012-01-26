var util = require('util');

var ROOT = -1;
var TERM = 0;
var STRING = 1;
var NUMBER = 2;
var LIST = 3;
var BOOLEAN = 4;
var VECTOR = 5;
var MAP = 6;

function node(type, data, children) {
    return {
        type: type,
        data: data,
        children: children || []
    };
}

function add_child(parent, child) {
    if(child) {
        return node(parent.type,
                    parent.data,
                    parent.children.concat([child]));
    }
    return parent;
}

function type_str(type) {
    switch(type) {
        case ROOT: return 'root';
        case TERM: return 'term';
        case STRING: return 'string';
        case NUMBER: return 'number';
        case LIST: return 'list';
        case BOOLEAN: return 'boolean';
        case VECTOR: return 'vector';
        case MAP: return 'map';
    }
    return 'unknown';
}

function pretty_print(ast, indent) {
    indent = indent || 0;

    function puts(str) {
        var pad = (new Array(indent+1)).join('-');
        if(indent > 0) {
            pad += ' ';
        }

        util.puts(pad + str);
    }

    if(!ast) {
        puts('undefined');
        return;
    }

    var data = '';
    if(ast.data !== null) {
        data = ': ' + util.inspect(ast.data);
    }

    if(ast === undefined || ast === null) {
        puts('NULL');
    }
    else {
        puts(type_str(ast.type) + data);    
    }
    

    for(var i=0; i<ast.children.length; i++) {
        pretty_print(ast.children[i], indent+2);
    }
}

module.exports = {
    ROOT: ROOT,
    TERM: TERM,
    NUMBER: NUMBER,
    STRING: STRING,
    LIST: LIST,
    BOOLEAN: BOOLEAN,
    VECTOR: VECTOR,
    MAP: MAP,

    node: node,
    add_child: add_child,
    pretty_print: pretty_print,
    type_str: type_str
};