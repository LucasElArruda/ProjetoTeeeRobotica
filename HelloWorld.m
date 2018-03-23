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
%handle para as partes desejadas do ePuck
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
%bodyElements=vrep.simxGetObjectHandle(clientID,'ePuck_bodyElements',vrep.simx_opmode_blocking);

% Definicoes de variaveis
wd = 53*10^-3   % wheel distance: 53 mm

minlim = 1;
maxlim = 16;

maxspeed = 0.6;
minspeed = 0.40;
%s=vrep.simxGetObjectSizeFactor(bodyElements) %Para caso o ePuck seja redimensionado
noDetectionDistance=0.05

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

[returnCode,detectionState1,detectedPoint1,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor1,vrep.simx_opmode_streaming)
[returnCode,detectionState2,detectedPoint2,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor2,vrep.simx_opmode_streaming)
[returnCode,detectionState3,detectedPoint3,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor3,vrep.simx_opmode_streaming)
[returnCode,detectionState4,detectedPoint4,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor4,vrep.simx_opmode_streaming)
[returnCode,detectionState5,detectedPoint5,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor5,vrep.simx_opmode_streaming)
[returnCode,detectionState6,detectedPoint6,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor6,vrep.simx_opmode_streaming)
[returnCode,detectionState7,detectedPoint7,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor7,vrep.simx_opmode_streaming)
[returnCode,detectionState8,detectedPoint8,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor8,vrep.simx_opmode_streaming)
for i = 1:400
    [returnCode,resolution,image]=vrep.simxGetVisionSensorImage2(clientID,lightSensor,1,vrep.simx_opmode_buffer);
    [returnCode,detectionState1,detectedPoint1,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor1,vrep.simx_opmode_buffer);
    [returnCode,detectionState2,detectedPoint2,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor2,vrep.simx_opmode_buffer);
    [returnCode,detectionState3,detectedPoint3,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor3,vrep.simx_opmode_buffer);
    [returnCode,detectionState4,detectedPoint4,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor4,vrep.simx_opmode_buffer);
    [returnCode,detectionState5,detectedPoint5,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor5,vrep.simx_opmode_buffer);
    [returnCode,detectionState6,detectedPoint6,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor6,vrep.simx_opmode_buffer);
    [returnCode,detectionState7,detectedPoint7,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor7,vrep.simx_opmode_buffer);
    [returnCode,detectionState8,detectedPoint8,~,~]=vrep.simxReadProximitySensor(clientID,proxSensor8,vrep.simx_opmode_buffer);
    if(detectionState6 ~= 0  )    %Gire bruscamente se tem algo em frente
        [returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,maxspeed,vrep.simx_opmode_oneshot);
        [returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,(maxspeed)*(wd-0.005),vrep.simx_opmode_oneshot);
    elseif(detectionState4 ~= 0)
        [returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,minspeed/4,vrep.simx_opmode_oneshot);
        [returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,maxspeed*4,vrep.simx_opmode_oneshot);
%     if(detectionState1 | detectionState2 | detectionState3 | detectionState4 | detectionState5 | detectionState6 | detectionState7 | detectionState8)
%         if(detectionState4 & detectionState5)
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
