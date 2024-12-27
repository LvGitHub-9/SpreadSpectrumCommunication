% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 伪随机码研究
% 文件名称：PnCode.m
% 版    本：V1.0
% 说    明：研究m序列、M序列、Gold序列以及Kasami序列
%           每块代码独立，不要一次全部执行
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2024-12-27       Lv.       序列生成器和性质研究
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 
%% 伪随机码研究
close all; clear; clc;

%% m序列相关性
close all; clear; clc;
initial=[1 0 1 1 0 0];          % 6阶
feedback=103;
m1 = mseq(initial,feedback,0);
m1 = 2*m1 - 1;

initial=[1 0 1 1 0 0];  % 6阶
feedback=147;
m2 = mseq(initial,feedback,0);
m2 = 2*m2 - 1;

subplot(3,1,1)
plot(xcorr(m1))                 % 自相关图
title('m1序列自相关图')
subplot(3,1,2)
plot(xcorr(m2))                 % 自相关图
title('m2序列自相关图')
subplot(3,1,3)
plot(xcorr(m1,m2))              % 互相关图
title('m1,m2序列互相关图')

%% m序列功率谱密度
close all; clear; clc;
T=0.005;                        % 码片周期5ms
fs=126e3;                       % 采样频率126kHz
ts=1/fs;                        % 采样间隔
t=0:ts:T-ts;                    % 时间轴
df=fs/length(t);                % 频率间隔
f=-fs/2:df:fs/2-df;             % 频率点

initial=[1 0 1 1 0 0];          % 6阶
feedback=103;
m = mseq(initial,feedback,0);
m = 2*m - 1;

x=rectpulse(m,length(t)/length(m));     % 脉冲成型/采样点数
mft=fft(x)/fs;                          % fft

subplot(3,1,1)
plot(t,x)
title('m序列时域信号')
subplot(3,1,2)
plot(xcorr(m))
title('m序列自相关函数')
axis([0 125 -9 length(m)])
subplot(3,1,3)
plot(f,fftshift(mft))
title('m序列功率谱密度')
axis([-62800 62800 -0.0006 0.0006])
% 如何计算带宽：先求门信号的FT，找出第一过零点带宽f=1/门信号宽度，
% 门信号宽度为5ms（总时间）/63（扩频码长）/10（脉冲成型/采样点数）

%% m序列优选对
% 两个反馈系数生成的m序列互相关函数小于一定值，称为m序列优选对
close all; clear; clc;
initial=[1 0 1 1 0 0];  		% 6阶
feedback=103;
m1 = mseq(initial,feedback,0);
m1 = 2*m1 - 1;

initial=[1 0 1 1 0 0]; 		 	% 6阶
feedback=147;
m2 = mseq(initial,feedback,0);
m2 = 2*m2 - 1;

% 互相关
a=xcorr(m1,m2);
disp(['最大值:',num2str(max(abs(a)))])
plot(a)

%% Gold序列相关函数
close all; clear; clc;
initial=[1 0 1 1 0 0];          % 6阶
feedback1=103;
feedback2=147;
[g1,g2]=goldseq(initial,feedback1,feedback2,20);
g1 = 2*g1 - 1;                  % 逻辑映射
g2 = 2*g2 - 1;

subplot(3,1,1)
plot(xcorr(g1))
title('g1 Gold序列自相关函数')
subplot(3,1,2)
plot(xcorr(g2))
title('g2 Gold序列自相关函数')
subplot(3,1,3)
plot(xcorr(g1,g2))
title('g1、g2 Gold序列互相关函数')

%% 平衡Gold序列
close all; clear; clc;
initial=[1 0 1 1 0 0];          % 6阶
feedback1=103;
feedback2=147;
[g1,g2]=goldseq(initial,feedback1,feedback2,20);
g1 = 2*g1 - 1;                  % 逻辑映射
g2 = 2*g2 - 1;

% 判断平衡Gold码
if(sum(g1)==1)
    if(sum(g2)==1)
        disp('是平衡Gold序列')
    end
end

%% m和M序列互相关函数特性
close all; clear; clc;
initial=[1 0 0 0 0 0]; 			% 6阶
feedback=103;
m1 = mseq(initial,feedback,0);
m1 = 2*m1 - 1;

initial=[1 0 0 0 0 0]; 			% 6阶
feedback=147;
m2 = mseq(initial,feedback,0);
m2 = 2*m2 - 1;
disp(['m序列互相关最大值',num2str(max(abs(xcorr(m1,m2))))])

initial=[1 0 0 0 0 0]; 			% 6阶
feedback=103;
m1 = mseq(initial,feedback,1);
m1 = 2*m1 - 1;

initial=[1 0 0 0 0 0]; 			% 6阶
feedback=147;
m2 = mseq(initial,feedback,1);
m2 = 2*m2 - 1;
disp(['M序列互相关最大值',num2str(max(abs(xcorr(m1,m2))))])

%% Kasami序列
close all; clear; clc;
initial=[1 0 1 1 0 0];          % 6阶
feedback=103;
k1 = kasamiseq(initial,feedback,0);
k1 = 2*k1-1;

initial=[1 0 1 1 0 0];			% 6阶
feedback=103;
k2 = kasamiseq(initial,feedback,2);
k2 = 2*k2-1;

% 平衡性
sum(k1)
sum(k2)

subplot(3,1,1)
plot(xcorr(k1))
title('k1 Kasami序列自相关函数')
subplot(3,1,2)
plot(xcorr(k2))
title('k2 Kasami序列自相关函数')
subplot(3,1,3)
plot(xcorr(k1,k2))
title('k1、k2 Kasami序列互相关函数')

