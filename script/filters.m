
% Chebyshev high-pass filter
clear all
close all
clc
figure;
[b,a] = cheby2(1,30,0.0000625,'high')
[h,f]=freqz(b,a);
plot(log10(f/pi),mag2db(abs(h)));
hold on
[b,a] = cheby2(1,30,0.00025,'high')
[h,f]=freqz(b,a);
plot(log10(f/pi),mag2db(abs(h)));
hold on
[b,a] = cheby2(1,30,0.002,'high')
[h,f]=freqz(b,a);
plot(log10(f/pi),mag2db(abs(h)));
[b,a] = cheby2(1,30,0.008,'high')
[h,f]=freqz(b,a);
plot(log10(f/pi),mag2db(abs(h)));
hold on
grid on
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude(dB)');
title('Chebyshev high-pass Filter');
figure;
pzmap(b,a)
zgrid
title('Chebyshev high-pass Filter');


% Chebyshev high-pass filter
clear all
close all
clc
figure;
[b,a] = cheby2(5,30,0.9999,'low')
[h,f]=freqz(b,a);
plot(log10(f/pi),mag2db(abs(h)));
hold on
[b,a] = cheby2(5,30,0.75,'low')
[h,f]=freqz(b,a);
plot(log10(f/pi),mag2db(abs(h)));
hold on
[b,a] = cheby2(5,30,0.325,'low')
[h,f]=freqz(b,a);
plot(log10(f/pi),mag2db(abs(h)));
[b,a] = cheby2(5,30,0.1875,'low')
[h,f]=freqz(b,a);
plot(log10(f/pi),mag2db(abs(h)));
hold on
grid on
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude(dB)');
title('Chebyshev low-pass Filter');
figure;
pzmap(b,a)
zgrid
title('Chebyshev low-pass Filter');
