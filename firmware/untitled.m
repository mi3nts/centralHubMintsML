%  plot(centralWithTargets.dateTime)
% plot(centralWithTargets.dateTime,centralWithTargets.pm10_mintsDataOPCN3)
centralWithTargets(centralWithTargets.CO2>5000,:) = [];
plot(centralWithTargets.dateTime,centralWithTargets.CO2,'r')
hold on 
% plot(centralWithTargets.dateTime,centralWithTargets.pm2_5_mintsDataOPCN3,'g')
% plot(centralWithTargets.dateTime,centralWithTargets.co,'g')
% plot(centralWithTargets.dateTime,centralWithTargets.co,'k')
while(true)
    cnNodesCalONN_03(1)
end