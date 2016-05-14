#!/bin/env perl6
multi MAIN (  :$start=Date.today.earlier(day=>1),
            :$state='CA,CD,CF,CG,F,NF,PD,PR,R,RS,R,S,TO' )
{
    # original # run('sacct','--format=jobid%12,JobName%35,MaxRSS,MaxVMSize,start,Elapsed,NodeList%11,ReqCPUS%2,ReqMem%8,Timelimit,State,Priority%5',"--start=$start", "--state=$state"); 
    # run('sacct','--format=jobid%12,JobName%51,start,Elapsed,NodeList%11,ReqCPUS%2,ReqMem%8,Timelimit,State,Priority%5',"--start=$start", "--state=$state"); 
    #
    run('sacct','--format=jobid%8,JobName%30,MaxRSS,MaxVMSize,start,Elapsed,NodeList%28,ReqCPUS%2,ReqMem%8,Timelimit,State,Priority%6',"--start=$start", "--state=$state"); 
}

multi MAIN ( 'mem', :$start=Date.today.earlier(week=>1),
            :$state='CA,CD,CF,CG,F,NF,PD,PR,R,RS,R,S,TO' )
{
    run('sacct','--format=JobName%61,MaxRSS,MaxVMSize,ReqMem%8,start,Elapsed,Timelimit,State', "--start=$start", "--state=$state"); 
}
