���ļ�����ҪΪErLang + Delphi��ص�ʾ����


��ʹ�ñ�ʾ��֮ǰ����Ӧ���Ȱ�װerlang���������µ�ַ���أ�
http://www.erlang.org/


���ļ����а������������д�Ĺ��ߣ�˵�����£�
(ע�⣺���в���Ӧ���������ϡ�ָ��Ŀ¼�½��У�����Դ�������д��п��ܻ�����Ч��!!! )
��������
  all.bat      : Ӧ�ý����ļ�����ϵͳ������·���ϣ�����������ִ�и�������ʱ��������
                 ����erlc.exe�����뵱ǰĿ¼�µ�����*.erl���룬�������ļ���ebinĿ¼�С�


  *\set_work.bat : ��Ŀ¼�г�������ļ�ʱ����ָ��Ŀ¼�е�erlang����Ӧ��������linux��
                   ���С���set_work.bat����������һ����Ϊ".erlang"���ļ������ļ�����
                   ��erl.exeʱ���Զ����ء����С�
                   
                   ��erl.exe�����ڲ�ͬ��������ʱ��ʹ�õ�cookie����ͬ��ֻ����ͬ��cookie
                   �Ľ�㣨����erl.exe�ķ�����/����ϵͳ���̣�����ͨѶ������set_work.bat
                   ����һ��.erlang�ļ���ʹerl.exe����ʱ�豸��������/���������ͬ��cookie��
                   
                   ������Ƿ�������SD2C 2008�Ͻ���ʾ��������ġ�
                   
                   �����DEMO�еķ���(ʾ��14~16)��������linux�ϵģ�����Ӧ����������������
                      > erl -sname messenger
                   ���к�������Ҫʾ����'messenger'���̽����Զ�����(����ͨ��set_work.bat
                   ��ʵ�ֵģ���������erl.exe�������Զ�ִ�еĴ���)��

  *\demo.bat   : �������е�Ŀ¼�¶���demo.bat��������������SD2C 2008���ҽ��е���ʾ��
                 �ڵ���ǰ��Ӧȷ��ִ�й�all.bat��������롣����ǿͻ��ˣ���Ӧ�ȱ�֤�����
                 ������������������linux�еķ���ˡ�
��������

���ļ����а�����ʾ�������ҵĻ���Ϊ�������õġ���������ʾ��ʱ�����²���Ӧ���޸ģ�Ȼ����룩��
��������
1). �޸ķ������ڵ�hostname�����£�
    messenger.erl          ��
    messenger_cli.erl      ��
    messenger_app.hrl
�ļ��У�server_node()����Ӧ���������з���Ľ������ơ�һ����˵����Ӧ��Ϊ���¸�ʽ��
  messenger@<����hostname>
����������hostname���������ַ�����ôӦ����һ�Ե����������������磺
  'messenger@aimingoo-desktop'

2). �޸�delphiʾ�������е�hostname��ip address���ڣ�
    server_manager_c.dpr  ��
    mess_m.pas
�ļ��У�
    hostname = 'AIMINGPAD';
    connect_host = 'aimingoo-desktop'; // set s_ipaddr for this host name
    s_ipaddr : TInAddr = (S_un_b: (s_b1: 192; s_b2: 168; s_b3:10; s_b4: 89));
Ӧ���������޸ģ�
    hostname      : ��ǰ���и�DELPHI����Ŀͻ�����hostname
    connect_host  : ���з������ˣ�������messenger��erlang�������ڷ���������hostname
    s_ipaddr      : �����������˵�IP��ַ����

3). ͬ������������ͻ��˵�cookie����
    set_work.bat          ��
    server_manager_c.dpr  ��
    mess_m.pas
�ļ��У��ҵ��ַ���'JWRKJTKHMIMBRHCFAXZL'����Ϊ��Ŀͻ�����cookie�ַ��������
��Ŀͻ�����cookie�ַ����ķ����ǣ�
  A: ������erlang shell, ע��һ��Ҫ�����������
    >erl -sname test
  B: Ȼ����erlang shell��ִ�����
    >auth:cookie().
    
4). ��ȷ����ķ�������ͻ�������ͨ�������ʹ�������(����virtual box)����ô��ע�ⲻҪ
ʹ��natģʽ���ӵ�host���������������host������ip����������������ʹhost�����������
ʹ��ip��host name���໥���ʡ�

���˿���ϵͳ��hosts�ļ��е�����֮�⣬�����Ҫ����windowsϵͳ�е�dns client���񣬲���ʹ
erlangͨ��host name���ʵ�������㡣���������������÷���
��������


�ܰ���(aimingoo)
12:10 2008-12-8