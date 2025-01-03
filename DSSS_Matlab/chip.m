%% chip（Kimi.ai生成的代码）
close all; clear; clc;

%% 参数设置
Fs = 100e3;      	% 采样频率（Hz）
t = 0:1/Fs:0.01;    % 时间向量，总时长为1秒
A = 1;              % 门信号的幅度
width = 0.0005;     % 门信号的宽度（秒）

%% 生成门信号
gateSignal = A * (t >= 0 & t <= width);

%% 计算傅里叶变换
fftResult = fft(gateSignal)/Fs;

%% 计算频率轴的值
n = length(fftResult);
f = (0:n-1)*(Fs/n);

%% 绘制门信号
figure;
subplot(2,1,1);
plot(t, gateSignal);
title('门信号');
xlabel('时间 (s)');
ylabel('幅度');
legend(['门宽:' num2str(width)])

%% 绘制傅里叶变换结果
subplot(2,1,2);
plot(f, abs(fftResult));
title('傅里叶变换结果');
xlabel('频率 (Hz)');
ylabel('幅度');
xlim([0, Fs/2]);

