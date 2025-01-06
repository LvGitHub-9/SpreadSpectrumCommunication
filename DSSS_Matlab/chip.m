% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 码片时间研究
% 文件名称：chip.m
% 版    本：V1.0
% 说    明：研究码片时间和信号频谱变化
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2025-1-6         Lv.          发布
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% 码片时间（chip）
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

