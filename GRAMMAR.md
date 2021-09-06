compound_statement : statement
               | statement ('semi' | 'newline') compound_statement

statement : assignment
          | expression

assignment_statement : variable '=' expression

function : 'fn' '->' 'lparen' function_parameters 'rparen' statement
         | 'fn' '->' 'lparen' function_parameters 'rparen' 'lbrace' statement_list 'rbrace'

function_parameters : function_parameter
                    | function_parameter 'comma' function_parameters
                    | empty

function_parameter : 'identifier'

function_call : 'identifier' 'lparen' function_call_parameters  'rparen'

function_call_parameters : statement
                         | statement 'comma' statement
                         | empty

empty:

expression : term
           | (('+' | '-') term)*
           | function
           | function_call

factor : '+' factor
       | '-' factor
       | 'number'
       | 'lparen' expression 'rparen'
       | variable

variable : 'identifier'