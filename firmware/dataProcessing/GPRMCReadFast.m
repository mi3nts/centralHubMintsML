
function mintsData = GPRMCReadFast(fileName,timeSpan)
    mintsData                       = tabularTextDatastore(fileName);
    mintsData.SelectedVariableNames =  {'dateTime', 'latitudeCoordinate', 'longitudeCoordinate'};
    mintsData                       = retime(table2timetable(mintsData.read),'regular',@mean,'TimeStep',timeSpan);
    mintsData.dateTime.TimeZone = "utc";
end