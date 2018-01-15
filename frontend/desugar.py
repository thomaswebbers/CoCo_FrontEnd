from util import ASTTransformer
from ast import Type, Operator, VarDef, ArrayDef, Assignment, Modification, \
        If, Block, VarUse, BinaryOp, IntConst, Return, While, Break


class Desugarer(ASTTransformer):
    def __init__(self):
        self.varcache_stack = [{}]

    def makevar(self, name):
        # Generate a variable starting with an underscore (which is not allowed
        # in the language itself, so should be unique). To make the variable
        # unique, add a counter value if there are multiple generated variables
        # of the same name within the current scope.
        # A variable can be tagged as 'ssa' which means it is only assigned once
        # at its definition.
        name = '_' + name
        varcache = self.varcache_stack[-1]
        occurrences = varcache.setdefault(name, 0)
        varcache[name] += 1
        return name if not occurrences else name + str(occurrences + 1)

    def visitFunDef(self, node):
        self.varcache_stack.append({})
        self.visit_children(node)
        self.varcache_stack.pop()

    def visitModification(self, m):
        # from: lhs op= rhs
        # to:   lhs = lhs op rhs
        self.visit_children(m)
        return Assignment(m.ref, BinaryOp(m.ref, m.op, m.value)).at(m)

#    def visitDoWhile(self, doNode):
#        # from: do{BODY} while(END)
#        # to:   BODY while(END){BODY}
#        self.visit_children(doNode)
#
#        #while on BODY (checking for cont & break
#        doBody = doNode.body.statements
#        bodyLen = len(doBody)
#        print('\n',bodyLen, '\n') # remove
#
#        for i in range(0,bodyLen):
#             if(str(doBody[i]) == 'break;'):
#                  return Block(doBody[0:i])
#             
#             elif(str(doBody[i]) == 'continue;'):
#                  return Block([Block(doBody[0:i]), While(doNode.cond, doNode.body)])
#             
#        return Block([doNode.body, While(doNode.cond, doNode.body)])

    def visitFor(self, forNode): #! added Visitfor, how is desugarer called
        # from: for(VARDEF to END) BLOCK
        # to:   {VARDEF VARDEF1 while (VARDEF.ID < "end"){ BLOCK ASSIGNMENT}
        #       assignment: VARDEF.ID = VARDEF.ID + 1
        #       vardef1:    (int, "end", END)

        self.visit_children(forNode)

        endVar = self.makevar("end")

        initEnd = VarDef(Type.get('int'), endVar, BinaryOp(forNode.end, Operator('-'), IntConst(1)))
        decrCount =  Assignment(VarUse(forNode.start.name),(BinaryOp(VarUse(forNode.start.name), Operator('-'), IntConst(1))))

        #initEnd = VarDef(Type.get('int'), endVar, IntConst(1))

        endCheck = BinaryOp(VarUse(forNode.start.name), Operator('<'), VarUse(endVar))
        incrCount = Assignment(VarUse(forNode.start.name),(BinaryOp(VarUse(forNode.start.name), Operator('+'), IntConst(1))))

        return Block([forNode.start, decrCount, initEnd, While(endCheck, Block([incrCount, forNode.body]))])
        
