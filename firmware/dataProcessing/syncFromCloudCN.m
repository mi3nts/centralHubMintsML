function [] = syncFromCloudCN(nodeIDs,mintsDataFolder,xu4Sync,piSync,jetsonSync)
    
    folderCheck(mintsDataFolder);
    
    for nodeIndex = 1: length(nodeIDs) 
        
        nodeIDXu4    = nodeIDs{nodeIndex}.nodeIDXu4;
        nodeIDPi     = nodeIDs{nodeIndex}.nodeIDPi;
        nodeIDJetson = nodeIDs{nodeIndex}.nodeIDJetson;
        
        if(xu4Sync & ~(nodeIDXu4=="xxxxxxxxxxxx"))
            folderCheck(strcat(mintsDataFolder,"/raw/",nodeIDXu4,"/"));
            system(strcat('rsync -avzrtu --exclude={"*.png","*.jpg"} -e "ssh -p 2222" mints@mintsdata.utdallas.edu:raw/',...
                    nodeIDXu4,"/ ",mintsDataFolder,"/raw/",nodeIDXu4,"/"));
            folderCheck(strcat(mintsDataFolder,"/reference/",nodeIDXu4,"/"));
            system(strcat('rsync -avzrtu --exclude={"*.png","*.jpg"} -e "ssh -p 2222" mints@mintsdata.utdallas.edu:test/',...
                    nodeIDXu4,"/ ",mintsDataFolder,"/raw/",nodeIDXu4,"/"));    
 
           display(strcat('rsync -avzrtu --exclude={"*.png","*.jpg"} -e "ssh -p 2222" mints@mintsdata.utdallas.edu:raw/',...
                    nodeIDXu4,"/ ",mintsDataFolder,"/raw/",nodeIDXu4,"/"))                
        end
        
        if(piSync & ~(nodeIDPi=="xxxxxxxxxxxx"))        
        folderCheck(strcat(mintsDataFolder,"/raw/",nodeIDPi,"/"));    
        system(strcat('rsync -avzrtu --exclude={"*.png","*.jpg"} -e "ssh -p 2222" mints@mintsdata.utdallas.edu:raw/',...
                nodeIDPi,"/ ",mintsDataFolder,"/raw/",nodeIDPi,"/"));  
        end
        
        if (jetsonSync & ~(nodeIDJetson=="xxxxxxxxxxxx"))
        folderCheck(strcat(mintsDataFolder,"/raw/",nodeIDJetson,"/"));    
        system(strcat('rsync -avzrtu --exclude={"*.png","*.jpg"} -e "ssh -p 2222" mints@mintsdata.utdallas.edu:raw/',...
                nodeIDJetson,"/ ",mintsDataFolder,"/raw/",nodeIDJetson,"/")); 
        end    
                
        if (jetsonSync & ~(nodeIDJetson=="xxxxxxxxxxxx"))
        folderCheck(strcat(mintsDataFolder,"/raw/",nodeIDJetson,"/"));    
        system(strcat('rsync -avzrtu -e "ssh -p 2222" mints@mintsdata.utdallas.edu:raw/',...
                nodeIDJetson,"/ ",mintsDataFolder,"/raw/",nodeIDJetson,"/")); 
        end   
        
    end
    
end



