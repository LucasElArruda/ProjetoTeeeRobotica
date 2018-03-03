% Verifica se o Vrep já está rodando no sistema, caso não esteja, abre o
% programa
ExeName = 'vrep.exe';
[~,msg] = system(['c:\windows\system32\tasklist.exe /fi "ImageName eq ' ExeName '"']);
IsOpen  = ~isempty(strfind(msg,ExeName));

if(~IsOpen)
    winopen('hello.ttt');
end

% Cria objeto do tipo remApi
vrep = remApi('remoteApi');

% Fecha possíveis simulações que estejam rodando
vrep.simxFinish(-1);

%% Seta variáveis para fazer a conexão com o Vrep
connectionAddress = '127.0.0.1';
connectionPort = 19997;
waitUntilConnected = true;
doNotReconnectOnceDisconnected = true;
timeOutInMs = 5000;
commThreadCycleInMs = 5;

%% Conecta com o Vrep
[clientID]=vrep.simxStart(connectionAddress,connectionPort,waitUntilConnected,doNotReconnectOnceDisconnected,timeOutInMs,commThreadCycleInMs);
