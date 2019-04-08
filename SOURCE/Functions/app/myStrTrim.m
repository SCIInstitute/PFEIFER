function str = myStrTrim(str)
%removes weird leading and trailing non-alphanum characters from str
if isempty(str), return, end

for p = 1:length(str)
    if isstrprop(str(p),'alphanum')
        start=p;
        break
    end
end
for p=length(str):-1:1
    if isstrprop(str(p),'alphanum')
        ending=p;
        break
    end
end

str=str(start:ending);
end
