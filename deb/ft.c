#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/wait.h>


const double time_out = 20.0;
const double STEP_TIME = 0.1;    // time step, second


int main(int argc, char** argv)
{
        if(argc == 3){
                ft_call(argv[2], atof(argv[1]));
        } else if (argc == 2) {
                ft_call(argv[1], time_out);
        } else {
                help(argv[0]);
        }
}

int help(char* name)
{
        printf("Useage: %s [timeout_in_second] command\n", name);
}

void fun(int sig)
{
        kill(0 , SIGKILL);
}



int ft_call(char *cmdstring, double timeout)
{
        setpgid(0,0);      //
        signal(SIGUSR1, fun );
        //signal(SIGCHLD, SIG_IGN);

        pid_t pid;
        int status;
        if (cmdstring == NULL)
        {
                return 1;
        }
        if ((pid = fork()) < 0) //fork出错
        {
                status = -1;
        }
        else if (pid == 0)  //子进程
        {
                execl("/bin/sh", "sh", "-c", cmdstring, (char*)0);
                // ?????
                _exit(127);
        }
        else
        {
                double left = timeout;
                double ret;

                while ((ret = waitpid(pid, &status, WNOHANG)) <= 0)
                {
                        // printf("wait %e\n", left);
                        usleep(STEP_TIME * 1000000); // use usleep to control
                        left -= STEP_TIME;
                        //time out
                        if (left <= 0)
                        {
                                status = 137;
                                kill(pid, SIGUSR1);
                                break;
                        }
                }
        }
        return status;
}
