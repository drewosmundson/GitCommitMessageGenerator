local PROMTS = {

    EVALUATE_COMMAND_OUTPUT = "", 

} 


what = {
    description = ""
    run = function(app, args) 
        local testCommand = args[2]
        io.popen(testCommand)
        return
    end
}




return what