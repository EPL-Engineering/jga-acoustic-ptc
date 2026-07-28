function Ygated = cos2window(Y, options)
arguments
   Y  (:,1) double
   options.SampleRate   (1,1) double = 1e5;
   options.Ramp         (1,1) double = 5;
   options.Duration     (1,1) double = Inf;
end

fs = options.SampleRate;
ramp = options.Ramp;
duration = options.Duration;

sinePeriod_s = 2 * ramp / 1000;
npts = round(sinePeriod_s * fs);
sineFrequency = 1 / sinePeriod_s;

sineBuffer = -cos(2*pi*sineFrequency*(0:npts-1)/fs);
sineBuffer = (sineBuffer + 1)/2;
sineBuffer = sineBuffer.^2;

%  Split the sinusoid in half and fill center with ones
numPoints = min(length(Y), round(fs * duration/1000));
numOnes = numPoints - length(sineBuffer);
N = length(sineBuffer);
G = zeros(size(Y));
G(1:numPoints) = [sineBuffer(1:round(N/2)) ones(1,numOnes) sineBuffer((round(N/2)+1):end)];

Ygated = Y .* G;
