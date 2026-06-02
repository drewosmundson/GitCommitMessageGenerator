local PROMTS = {

    EVALUATE_COMMAND_OUTPUT = "", 

} 


return {
    description = ""
    run = function(app, args) 
        local testCommand = args[2]
        io.popen(testCommand)
        

} 