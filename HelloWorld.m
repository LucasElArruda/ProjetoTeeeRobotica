% Verifica se o Vrep j� est� rodando no sistema, caso n�o esteja, abre o
% programa
ExeName = 'vrep.exe';
[~,msg] = system(['c:\windows\system32\tasklist.exe /fi "ImageName eq ' ExeName '"']);
IsOpen  = ~isempty(strfind(msg,ExeName));

if(~IsOpen)
    winopen('hello.ttt');
end

% Cria objeto do tipo remApi
vrep = remApi('remoteApi');

% Fecha poss�veis simula��es que estejam rodando
vrep.simxFinish(-1);

%% Seta vari�veis para fazer a conex�o com o Vrep
connectionAddress = '127.0.0.1';
connectionPort = 19997;
waitUntilConnected = true;
doNotReconnectOnceDisconnected = true;
timeOutInMs = 5000;
commThreadCycleInMs = 5;

%% Conecta com o Vrep
[clientID]=vrep.simxStart(connectionAddress,connectionPort,waitUntilConnected,doNotReconnectOnceDisconnected,timeOutInMs,commThreadCycleInMs);

%handle pro motor esquerdo
[returnCode,leftWheel]=vrep.simxGetObjectHandle(clientID,'ePuck_leftJoint',vrep.simx_opmode_blocking)
[returnCode,rightWheel]=vrep.simxGetObjectHandle(clientID,'ePuck_rightJoint',vrep.simx_opmode_blocking)


% Inicia simula��o do vrep
[returnCode] = vrep.simxStartSimulation(clientID,vrep.simx_opmode_oneshot);

%roda o boneco
[returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,5,vrep.simx_opmode_blocking)
[returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,0,vrep.simx_opmode_blocking)



pause(10)

vrep.simxStopSimulation(clientID,vrep.simx_opmode_oneshot_wait);


vrep.simxFinish(clientID);

vrep.delete();
