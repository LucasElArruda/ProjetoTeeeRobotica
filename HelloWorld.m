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
retCod = 0;
while(retCod == 0)
    [clientID]=vrep.simxStart(connectionAddress,connectionPort,waitUntilConnected,doNotReconnectOnceDisconnected,timeOutInMs,commThreadCycleInMs);
    if(clientID > -1),
        fprintf('Starting\n');
        retCod = 1;
    else
        fprintf ('Waiting\n');
    end
end
%handle pro motor esquerdo
[returnCode,leftWheel]=vrep.simxGetObjectHandle(clientID,'ePuck_leftJoint',vrep.simx_opmode_blocking);
[returnCode,rightWheel]=vrep.simxGetObjectHandle(clientID,'ePuck_rightJoint',vrep.simx_opmode_blocking);
[returnCode,lightSensor]=vrep.simxGetObjectHandle(clientID,'ePuck_lightSensor',vrep.simx_opmode_blocking);
[returnCode,proxSensor1]=vrep.simxGetObjectHandle(clientID,'ePuck_proxSensor1',vrep.simx_opmode_blocking);
[returnCode,proxSensor2]=vrep.simxGetObjectHandle(clientID,'ePuck_proxSensor2',vrep.simx_opmode_blocking);
[returnCode,proxSensor3]=vrep.simxGetObjectHandle(clientID,'ePuck_proxSensor3',vrep.simx_opmode_blocking);
[returnCode,proxSensor4]=vrep.simxGetObjectHandle(clientID,'ePuck_proxSensor4',vrep.simx_opmode_blocking);
[returnCode,proxSensor5]=vrep.simxGetObjectHandle(clientID,'ePuck_proxSensor5',vrep.simx_opmode_blocking);
[returnCode,proxSensor6]=vrep.simxGetObjectHandle(clientID,'ePuck_proxSensor6',vrep.simx_opmode_blocking);
[returnCode,proxSensor7]=vrep.simxGetObjectHandle(clientID,'ePuck_proxSensor7',vrep.simx_opmode_blocking);
[returnCode,proxSensor8]=vrep.simxGetObjectHandle(clientID,'ePuck_proxSensor8',vrep.simx_opmode_blocking);

minlim = 1;
maxlim = 16;

maxspeed = 0.6;
minspeed = 0.40;

% Inicia simulação do vrep
[returnCode] = vrep.simxStartSimulation(clientID,vrep.simx_opmode_oneshot);

%roda o boneco
[returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,0.5,vrep.simx_opmode_oneshot);
[returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,0.5,vrep.simx_opmode_oneshot);
%[returnCode,~,detectedPoint,detectedObjectHandle,~]=vrep.simxReadProximitySensor(clientID,lightSensor,vrep.simx_opmode_streaming);
image = zeros(2,16);
[returnCode,resolution,image]=vrep.simxGetVisionSensorImage2(clientID,lightSensor,1,vrep.simx_opmode_streaming)
upperhalf = (resolution(1)/2 + 1):resolution(1);
lowerhalf = 1:(resolution(1)/2);

[returnCode,detectionState,detectedPoint,detectedObjectHandle,~]=vrep.simxReadProximitySensor(clientID,proxSensor4,vrep.simx_opmode_streaming)
for i = 1:1000
    [returnCode,resolution,image]=vrep.simxGetVisionSensorImage2(clientID,lightSensor,1,vrep.simx_opmode_buffer);
    [returnCode,detectionState,detectedPoint,detectedObjectHandle,~]=vrep.simxReadProximitySensor(clientID,proxSensor4,vrep.simx_opmode_buffer)
    if(detectionState~= 0)
        [returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,minspeed/2,vrep.simx_opmode_oneshot);
        [returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,2*maxspeed,vrep.simx_opmode_oneshot);
    elseif(~isempty(image))
        image(image>128) = 200;
        image(image <100) = 0;

        if(~isempty(find(image(:,1:8)>image(:,  9:end))))
            [returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,maxspeed,vrep.simx_opmode_oneshot);
            [returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,minspeed,vrep.simx_opmode_oneshot);
        end
        if(~isempty(find(image(:,1:8)<image(:,  9:end))))
            [returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,maxspeed,vrep.simx_opmode_oneshot);
            [returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,minspeed,vrep.simx_opmode_oneshot);
        end
%     else
%         [returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,maxspeed,vrep.simx_opmode_oneshot);
%         [returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,minspeed,vrep.simx_opmode_oneshot);
    end
    
    pause(0.01 )
end
%pause(3)

vrep.simxStopSimulation(clientID,vrep.simx_opmode_oneshot_wait);


vrep.simxFinish(clientID);

vrep.delete();
