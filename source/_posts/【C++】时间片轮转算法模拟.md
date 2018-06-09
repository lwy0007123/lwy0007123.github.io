---
title: 【C++】时间片轮转算法模拟
date: 2016-11-20 20:03:13
categories: C++
tags: 
- C++ 
- 操作系统
- 时间片轮转
---

### 就一个链式队列实现进程控制块的扔来扔去，不说了直接贴代码
* *主要代码*

```c++
#include <bits/stdc++.h>
using namespace std;

typedef struct pcb
{
    char Name[256]; //进程名
    int ArriveTime; //到达时间
    int ServeTime; //服务时间
    int cpuTime; //cpu执行时间
    char status; //进程状态 C-Coming, W-Wait, R-Run, F-Finish
    struct pcb *next; //向下一个pcb

    int finishTime; //完成时间
    int RoundTime; //周转时间
    double WRoundTime; //带权周转时间
}*PCB;

struct LinkPCB
{
    PCB Front;
    PCB Rear;
};

int pTime; //时间片大小
int now; //时间线
void PrintPCB(pcb* k); //打印pcb
void PrintTitle(); //打印表头
void PrintLinkPCB(LinkPCB* k); //打印pcb队列
void InitQueue(LinkPCB* p); //初始化队列
bool isEmpty(LinkPCB* p); //判断队列是否为空
bool EnQueue(LinkPCB* p, pcb* e); //入队，将e入队
bool DeQueue(LinkPCB* p, pcb* e); //出队，出队到e
void FromA2B(LinkPCB* a, LinkPCB* b, char st); //出队列a，进队列b，改变状态为st
void create(LinkPCB* head); //创建pcb列表
void Test(LinkPCB* head); //队列测试函数
void RoundRobin(LinkPCB *head); //时间片轮转调度模拟

LinkPCB HEAD;
int main()
{
    create(&HEAD);
    RoundRobin(&HEAD);
    return 0;
}
```

* *函数实现*

```c++
void PrintPCB(pcb* k)
{
    printf("%s\t%c\t%d\t%d\n", k->Name, k->status, k->ServeTime, k->cpuTime);
}

void PrintTitle()
{
    cout << "name\tstatus\tserve\tcpu\n";
}

void PrintLinkPCB(LinkPCB* k)
{
    pcb* p = k->Front->next;
    while (p)
    {
        PrintPCB(p);
        p = p->next;
    }
}

void InitQueue(LinkPCB* p)
{
    p->Front = p->Rear = new pcb;
    p->Front->next = NULL;
    p->Rear->next = NULL;
}

bool isEmpty(LinkPCB* p)
{
    return p->Front == p->Rear;
}

bool EnQueue(LinkPCB* p, pcb* e)
{
    if (e)
    {
        e->next = NULL;
        p->Rear->next = e;
        p->Rear = e;
        return true;
    }
    else
        return false;
}

bool DeQueue(LinkPCB* p, pcb* e)
{
    if (p->Rear == p->Front)
        return false;
    pcb* top = p->Front->next;
    *e = *top; // important
    p->Front->next = top->next;
    if (p->Rear == top)
    {
        p->Rear = p->Front;
    }
    return true;
}

void FromA2B(LinkPCB* a, LinkPCB* b, char st)
{
    pcb* p = new pcb;
    DeQueue(a, p);
    p->status = st;
    EnQueue(b, p);
    switch (st)
    {
    case 'W': cout << p->Name << " is waiting\ttime: " << now << "\n"; break;
    case 'R': cout << p->Name << " is running\ttime: " << now << "\n"; break;
    case 'F':
        cout << p->Name << " is finish\ttime: " << now << "\n";
        p->finishTime = now;
        p->RoundTime = p->finishTime-p->ArriveTime;
        p->WRoundTime = 1.0*p->RoundTime/p->ServeTime;
        break;
    case 'C':
    default: cout << "......" << endl;
    }
}

void create(LinkPCB* head)
{
    InitQueue(head);
    cout << "请输入时间片大小：";
    cin >> pTime;
    cout << "请输入要创建的进程数：";
    int n;
    cin >> n;
    for (int i = 1; i <= n; i++)
    {
        pcb* ft = head->Front->next;
        pcb* p = new pcb; // important
        printf("输入第%d个进程的“ 进程名 到达时间 服务时间” （以空格隔开）", i);
        char Name[256];
        int Atime, Stime;
        cin >> Name >> Atime >> Stime;

        if (Atime >= 0 && Stime >= 0)
        {
            strcpy(p->Name, Name);
            p->ArriveTime = Atime;
            p->ServeTime = Stime;
            p->cpuTime = 0;
            p->status = 'C';
            p->next = NULL;

            // sort
            if (ft == NULL)
            {
                EnQueue(head, p);
            }
            else if (p->ArriveTime < ft->ArriveTime)
            {
                p->next = ft;
                head->Front->next = p;
            }
            else
            {
                pcb* a = ft;
                pcb* b = a->next;
                bool flag = true;
                while (b)
                {
                    if (p->ArriveTime < b->ArriveTime)
                    {
                        p->next = b;
                        a->next = p;
                        b = NULL;
                        flag = false;
                        break;
                    }
                    else
                    {
                        a = a->next;
                        b = b->next;
                    }
                }
                if (flag)
                {
                    EnQueue(head, p);
                }
            }
        }
        else
        {
            cout << "输入错误,请重输!" << endl;
            i--;
            continue;
        }
        // PrintLinkPCB(head);
    }
}

void Test(LinkPCB* head)
{
    InitQueue(head);
    while (true)
    {
        cout << "1.EnQueue 2.DeQueue 3.Print";
        int ch;
        cin >> ch;
        pcb* p = new pcb;
        switch (ch)
        {
        case 1:
            cout << "input: name atime stime" << endl;
            char Name[256];
            int Atime, Stime;
            cin >> Name >> Atime >> Stime;
            strcpy(p->Name, Name);
            p->ArriveTime = Atime;
            p->ServeTime = Stime;
            p->cpuTime = 0;
            p->status = 'W';
            p->next = NULL;
            EnQueue(head, p);
            break;
        case 2:
            if (DeQueue(head, p))
                PrintPCB(p);
            break;
        case 3:
        default:
            PrintLinkPCB(head);
        }
    }
}

void RoundRobin(LinkPCB *head)
{
    LinkPCB *ready = new LinkPCB;
    LinkPCB *run = new LinkPCB;
    LinkPCB *finish = new LinkPCB;
    InitQueue(ready);
    InitQueue(run);
    InitQueue(finish);

    now = head->Front->next->ArriveTime; //开始时刻
    FromA2B(head, ready, 'W');

    while (!(isEmpty(head) && isEmpty(ready)))
    {
        int Tnow = now; //备份开始时刻

        while (!isEmpty(head))
        {
            pcb* t = head->Front->next;
            if (now >= t->ArriveTime)
            {
                FromA2B(head, ready, 'W');
            } else break;
        }

        if (!isEmpty(ready))
        {
            FromA2B(ready, run, 'R');
            pcb* p = run->Front->next;
            if (p->ServeTime - p->cpuTime <= pTime) //时间片内完成
            {
                now += p->ServeTime - p->cpuTime;
                p->cpuTime = p->ServeTime;
                FromA2B(run, finish, 'F');
            }
            else
            {
                now += pTime;
                p->cpuTime += pTime;
                FromA2B(run, ready, 'W');
            }
        }

        if (Tnow == now) //若没发生轮转，时间继续推移
        {
            now++;
            continue;
        }

        PrintTitle();
        PrintLinkPCB(head);
        PrintLinkPCB(run);
        PrintLinkPCB(ready);
        PrintLinkPCB(finish);
        cout << "time: " << now << endl;
    }

    // result
    pcb* p = finish->Front->next;
    cout << "Result:\n";
    while (p)
    {
        printf("Name: %s\tFinishtime: %d\tRoundtime: %d\twRoundtime: %.2f\n", p->Name, p->finishTime, p->RoundTime, p->WRoundTime);
        p = p->next;
    }
}
```

