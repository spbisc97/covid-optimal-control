function tableData = onlineData(fname, url)
try
    websave(fname, url);
catch
    error('github impossible to reach');
end
%opts= detectImportOptions(fname,"VariableNamesLine",1)
try
    tableData=readtable(fname);
catch
    error('no file for data');
end
end

