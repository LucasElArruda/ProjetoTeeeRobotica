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




% Inicia simula��o do vrep
[returnCode] = vrep.simxStartSimulation(clientID,vrep.simx_opmode_oneshot);

%roda o boneco
[returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,0.5,vrep.simx_opmode_oneshot);
[returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,0.5,vrep.simx_opmode_oneshot);
%[returnCode,~,detectedPoint,detectedObjectHandle,~]=vrep.simxReadProximitySensor(clientID,lightSensor,vrep.simx_opmode_streaming);
image = zeros(2,16);
[returnCode,resolution,image]=vrep.simxGetVisionSensorImage2(clientID,lightSensor,1,vrep.simx_opmode_streaming)

for i = 1:2000
    [returnCode,resolution,image]=vrep.simxGetVisionSensorImage2(clientID,lightSensor,1,vrep.simx_opmode_buffer);
    if(~isempty(image))
        image(image>200) = 200;
        image(image <40) = 0;
        if(image(1,8) > image(2,8) || image(1,1) > image(2,1) || image(1,16) > image(2,16) )
            [returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,0.85,vrep.simx_opmode_oneshot);
            [returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,0.15,vrep.simx_opmode_oneshot);
        end
        if(image(1,8) < image(2,8) || image(1,1) < image(2,1) || image(1,16) < image(2,16) )
            [returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,0.85,vrep.simx_opmode_oneshot);
            [returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,0.15,vrep.simx_opmode_oneshot);
        end
%         if(image(1,8) == image(2,8))
%             [returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,0.5,vrep.simx_opmode_oneshot);
%             [returnCode]=vrep.simxSetJointTargetVelocity(clientID,leftWheel,0.5,vrep.simx_opmode_oneshot);
%         end
        
    end
%     image(i).setdatatype('uint8Ptr',1,resolution(1)*resolution(2)*1);
%     if(image(i).Value(1) == 0)
%         [returnCode]=vrep.simxSetJointTargetVelocity(clientID,rightWheel,0.5,vrep.simx_opmode_oneshot);
%     end
    %[returnCode,~,detectedPoint(i,1:3),detectedObjectHandle,~]=vrep.simxReadProximitySensor(clientID,lightSensor,vrep.simx_opmode_buffer);
    pause(0.01 )
end
%pause(3)

vrep.simxStopSimulation(clientID,vrep.simx_opmode_oneshot_wait);


vrep.simxFinish(clientID);

vrep.delete();
