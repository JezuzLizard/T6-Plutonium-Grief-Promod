# Structure

Commands are parsed in a very easy to understand way if you are somewhat familiar with any programming language.
Essentially you just need to understand each command and how they work in order to get the outcome you want.
Each command can have namespace(a method of shortening names), the name of the command, and no args to varargs(meaning you can send a large number of args to most commands). The parser does attempt to verify if the arg type is the same as the expected type.

## Commands
Valid types:

Bool(bool): 0, 1, false, true

Int(int): Same as normal int

Float(float): Requires exactly one decimal point(.) otherwise will be treated as an int

Vector(vec): Needs to be input in exactly this format (170932,-11233,231980.4)

String(str): If a value isn't any of the previous types its automatically a string

```
add(str:player_name,str:team_name,bool:is_perm,bool:is_banned);
//Example = 
add(JezuzLizard,axis,1,0);
```