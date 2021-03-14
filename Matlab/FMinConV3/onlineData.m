function tableData = onlineData(fname, url)
    websave(fname, url);
    %opts= detectImportOptions(fname,"VariableNamesLine",1)
    tableData=readtable(fname);
end

