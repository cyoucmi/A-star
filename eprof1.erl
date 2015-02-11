-module(eprof1).
-compile([export_all]).
prof(Mod, Fun, Args)->
    eprof:start(),
    eprof:profile([self()], Mod, Fun, Args), %启动待测试程序
    eprof:stop_profiling(),
    eprof:analyze(),
    eprof:stop().
    
