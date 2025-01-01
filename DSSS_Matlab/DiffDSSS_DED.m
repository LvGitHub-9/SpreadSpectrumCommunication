% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 直接序列扩频的频域差分能量检测
% 文件名称：DiffDSSS_DED.m
% 版    本：V1.0
% 说    明：差分直扩方式的频域能量检测方法，相较于时域差分检测，在单片机
%           平台用DSP库和FPU实现更快
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2025-1-1         Lv.          发布
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% 差分直接序列扩频-差分能量检测
close all; clear; clc;

%% 消息生成
bits=8;                        % 消息个数
mes=randi([0,1],1,bits);    
bimes=2*mes-1;                  % 单极性码转双极性,BPSK  

%% 差分编码
diffmes(1)=1;
for i=1:bits                    % 差分编码，只传输变化量，相位问题
    diffmes(i+1)=bimes(i)*diffmes(i);
end

%% 扩频码生成（使用m序列）
initial=[1 0 1 1 0 0];          % 6阶       
feedback=103;
m=mseq(initial,feedback,0);
L=length(m);                    % 取m序列长度
m=2*m-1;                        % 逻辑映射

%% 扩频
kmes=kron(diffmes,m);           % 克罗内克积

%% 脉冲成型
% 假设我需要的通信速率是200bps，一秒接收200个消息bit，就是5ms一个bit
% 假设发送频率48kHz，一秒发送48000个符号
% 根据发送频率，5ms可以发送48k*5ms=240个符号
% 扩频方式，一个消息bit长度是63
% 每个符号需要重复发送240/63=3.81，向上取整是4次
% 如果设置bits=200，脉冲成型长度为4，rmes的长度为50.4K，差不多一秒发完
rect=4;
rmes=rectpulse(kmes,rect);

%% 参数
fc=6e3;                         % 载波频率6kHz
fb=4e3;                         % 带宽4kHz
fs=48e3;                        % 采样频率48kHz
ts=1/fs;                        % 时域采样间隔
T=length(rmes)/fs;              % 发送时间
t=0:ts:T-ts;                    % 时域时间点
% df=fs/length(t);                % 频率间隔
% f=-fs/2:df:fs/2-df;             % 频域频率点

%% 上变频
mmes=rmes.*cos(2*pi*fc*t);      % 调制

%% 信道
% 不加信道
% ymes=rmes;

% 加AWGN信道
SNR=0;                          % 信噪比
ymes=awgn(kmes,SNR);

%% 下变频
dmmes=mmes.*cos(2*pi*fc*t);     % 解调

%% 低通滤波
Delay = 32;                     % 32阶滤波器
fircoef = fir1(2*Delay,fb/fs);
lpf = filter(fircoef,1,[dmmes zeros(1,Delay)]);
fmes = lpf(Delay+1:end);

%% 解扩方法2：频域差分能量检测
% 原理：自相关函数等同于conv(x(t),x(-t))
en=zeros(1,bits);               % 存储解扩序列
W=floor(L/4);                   % 选取自相关峰值窗口的长度

PN1=[m,m];
PN2=[m,-m];
iPN1=fft(fliplr(PN1));              % 频域副本
iPN2=fft(fliplr(PN2));

figure
hold on
for i=1:bits
    sym=fmes(1,1+(i-1)*L*rect:(i+1)*L*rect);        % 取出一个符号长度
    for ii=1:2*L                        % 解脉冲成型
        buf(ii)=sum(sym(1,1+(ii-1)*rect:ii*rect));
    end
    ibuf=fft(buf);                      % 接收信号做FFT
    ien1=iPN1.*ibuf;                    % 频域相乘
    ien2=iPN2.*ibuf;
    
    Pncor1=ifft(ien1);                  % iFFT
    Pncor2=ifft(ien2);

    subplot(2,bits,i)                   % 作图
    plot(Pncor1)
    axis([1 2*L -2*L 2*L])
    subplot(2,bits,i+bits)
    plot(Pncor2)
    axis([1 2*L -2*L 2*L])

    cor1=(Pncor1(1,L-W:L+W)).^2;        % 选窗口求相关峰
    cor2=(Pncor2(1,L-W:L+W)).^2;

    if(max(abs(cor1))>max(abs(cor2)))
        en(i)=1;
    else
        en(i)=-1;
    end
end

%% 误码率
A=find(en~=bimes);
BER=length(A)/bits;
disp(['解码误码率：' num2str(BER)])
