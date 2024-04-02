function value = getsharedpref(name, pref, defaultValue)

if nargin < 3, defaultValue = []; end
value = defaultValue;

prefPath = 'C:\ProgramData\EPL\sharedprefs.mat';

if exist(prefPath, 'file')
   load(prefPath, 'Prefs');
   if isfield(Prefs, name) && isfield(Prefs.(name), pref)
      value = Prefs.(name).(pref);
   elseif ispref(name, pref)
      value = getpref(name, pref);
   end
elseif ispref(name, pref)
   value = getpref(name, pref);
end
