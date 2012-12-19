本文件包主要为ErLang + Delphi相关的示例。


在使用本示例之前，你应该先安装erlang，请至如下地址下载：
http://www.erlang.org/


本文件包中包括多个批处理写的工具，说明如下：
(注意：所有操作应当在命令上、指定目录下进行，在资源管理器中打开有可能会是无效的!!! )
－－－－
  all.bat      : 应该将该文件放在系统的搜索路径上，在命令行上执行该批处理时，它将会
                 调用erlc.exe来编译当前目录下的所有*.erl代码，并生成文件到ebin目录中。


  *\set_work.bat : 当目录中出现这个文件时，是指该目录中的erlang代码应该运行在linux环
                   境中。而set_work.bat则用于生成一个名为".erlang"的文件，该文件在启
                   动erl.exe时会自动加载、运行。
                   
                   当erl.exe运行在不同的主机上时，使用的cookie并不同。只有相同的cookie
                   的结点（运行erl.exe的服务器/操作系统进程）才能通讯。所以set_work.bat
                   生成一个.erlang文件，使erl.exe启动时设备与管理程序/其它结点相同的cookie。
                   
                   这仅仅是方便我在SD2C 2008上进行示例而处理的。
                   
                   如果本DEMO中的服务(示例14~16)是运行在linux上的，则它应以如下命令启动：
                      > erl -sname messenger
                   运行后，我们需要示例的'messenger'进程将会自动启动(这是通过set_work.bat
                   来实现的，它设置了erl.exe启动后自动执行的代码)。

  *\demo.bat   : 几乎所有的目录下都有demo.bat，它用于启动在SD2C 2008中我进行的演示。
                 在调用前，应确保执行过all.bat来编译代码。如果是客户端，则应先保证服务端
                 被启动——例如启动linux中的服务端。
－－－－

本文件包中包括的示例是以我的机器为参数设置的。在你运行示例时，以下参数应被修改（然后编译）：
－－－－
1). 修改服务所在的hostname。如下：
    messenger.erl          或
    messenger_cli.erl      或
    messenger_app.hrl
文件中，server_node()函数应返回你运行服务的结点的名称。一般来说，它应该为如下格式：
  messenger@<主机hostname>
如果你的主机hostname带有特殊字符，那么应该用一对单引号括起来，例如：
  'messenger@aimingoo-desktop'

2). 修改delphi示例代码中的hostname和ip address。在：
    server_manager_c.dpr  或
    mess_m.pas
文件中，
    hostname = 'AIMINGPAD';
    connect_host = 'aimingoo-desktop'; // set s_ipaddr for this host name
    s_ipaddr : TInAddr = (S_un_b: (s_b1: 192; s_b2: 168; s_b3:10; s_b4: 89));
应当被如下修改：
    hostname      : 当前运行该DELPHI程序的客户机的hostname
    connect_host  : 运行服务器端（即启动messenger的erlang进程所在服务器）的hostname
    s_ipaddr      : 上述服务器端的IP地址配置

3). 同步服务器端与客户端的cookie。在
    set_work.bat          或
    server_manager_c.dpr  或
    mess_m.pas
文件中，找到字符串'JWRKJTKHMIMBRHCFAXZL'，改为你的客户机的cookie字符串。获得
你的客户机的cookie字符串的方法是：
  A: 先启动erlang shell, 注意一定要带结点名启动
    >erl -sname test
  B: 然后在erlang shell中执行命令：
    >auth:cookie().
    
4). 请确保你的服务器与客户机能连通。如果你使用虚拟机(例如virtual box)，那么请注意不要
使用nat模式连接到host机——这种情况下host不能用ip连接虚拟机。你必须使host机与虚拟机能
使用ip和host name来相互访问。

除了考虑系统的hosts文件中的配置之外，你可以要开启windows系统中的dns client服务，才能使
erlang通过host name访问到其它结点。建议你总是启动该服务。
－－－－


周爱民(aimingoo)
12:10 2008-12-8