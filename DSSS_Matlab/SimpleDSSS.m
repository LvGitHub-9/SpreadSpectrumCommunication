% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 简化直接序列扩频DSSS
% 文件名称：SimpleDSSS.m
% 版    本：V1.0
% 说    明：省略掉脉冲成型、上下变频与信道过程，仅研究扩频与解扩
%           没有脉冲成型，研究频谱没有什么意义
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2025-1-1         Lv.          发布
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% 简化直接序列扩频
close all; clear; clc;

%% 消息生成
bits=10;                        % 消息个数
mes=randi([0,1],1,bits);    
bimes=2*mes-1;                  % 单极性码转双极性,BPSK      

%% 扩频码生成（使用m序列）
initial=[1 0 1 1 0 0];          % 6阶       
feedback=103;
m=mseq(initial,feedback,0);
L=length(m);                    % 取m序列长度
m=2*m-1;                        % 逻辑映射
clear initial feedback

%% 直接扩频
kmes=kron(bimes,m);             % 克罗内克积

%% 省略上变频，信道，下变频过程仅研究扩频和解扩过程
% 不加信道
% ymes=kmes;

% 加AWGN信道
SNR=0;                          % 信噪比
ymes=awgn(kmes,SNR);

%% 相关解扩
en=zeros(1,bits);               % 存储解扩序列
ex=[];                          % 存储自相关后的序列
W=floor(L/4);                   % 选取自相关峰值窗口的长度
buf=zeros(1,L);                 % 存储一个符号长度
conj=zeros(1,2*W);              % 在自相关函数中选取峰值窗口
                                % 用于判断峰值正负
for i=1:bits
    buf=ymes(1,1+(i-1)*L:i*L);      % 取出一个符号长度
    cor=xcorr(buf,m);               % 做自相关
    conj=cor(1,L-W:L+W);            % 选取自相关窗口
    ex=[ex cor];                    % 保存自相关函数
    if(max(conj)>abs(min(conj)))    % 判断自相关峰值正负，解扩
        en(i)=1;
    else
        en(i)=0;
    end
end

%% 误码率
A=find(en~=mes);                    % 计算误码率
BER=length(A)/bits;
disp(['解码误码率：',num2str(BER)])

%% 作图
subplot(3,1,1)
stem(mes)
title('消息序列');
axis([0.5 0.5+bits 0 1]);
subplot(3,1,2)
plot(kmes)
axis([0 length(kmes) -1 1]);
title('扩频序列');
subplot(3,1,3)
plot(ex)
title('解扩自相关峰值');
axis([0 length(ex) -63 63]);

