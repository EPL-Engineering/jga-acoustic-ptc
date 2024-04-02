function setsharedpref(name, pref, value)

prefPath = 'C:\ProgramData\EPL\sharedprefs.mat';

if exist(prefPath, 'file')
   load(prefPath, 'Prefs');
   Prefs.(name).(pref) = value;
   save(prefPath, 'Prefs', '-append');
else
   Prefs.(name).(pref) = value;
   save(prefPath, 'Prefs');
end

