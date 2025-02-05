% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: 循环移位键控扩频
% 文件名称：CSK.m
% 版    本：V1.0
% 说    明：循环移位键控扩频的扩频解扩过程实现
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2025-1-2         Lv.          发布
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% 循环移位键控扩频(Cyclic Shift Keyed Spread Spectrum,BCSKSS)
close all; clear; clc;

%% 消息生成
bits=20;                            % 消息个数
mes=randi([0,1],1,bits);
mary=2;                             % mary进制信源
p=rem(length(mes),mary);            % bit补齐
if(p~=0)
    mes=[mes zeros(1,mary-p)];
end
rmes=reshape(mes,mary,[])';         % 串并转换
bimes=bi2de(rmes);                  % 4进制，2比特

%% CSK序列生成
initial=[1 0 1 1 0 0];              % 6阶
feedback1=103;
feedback2=147;

m1 = mseq(initial,feedback1,0);
m2 = mseq(initial,feedback2,0);
L=length(m2);                       % 扩频码长
gold=2*(mod(m1+m2,2)) - 1;          % 原始扩频码

csk=[];                             % csk扩频码矩阵
csk(1,:)=circshift(gold,24);
csk(2,:)=circshift(gold,8);
csk(3,:)=circshift(gold,-8);
csk(4,:)=circshift(gold,-24);

% 作互相关函数图
figure
subplot(2,1,1)
plot(xcorr(gold))
title('7阶数gold序列自相关性');
subplot(2,1,2)
hold on
for i=1:4
    plot(xcorr(gold,csk(i,:)));
end
title('gold序列循环移位后互相关性');
legend('00','01','10','11')

%% 扩频码选择
ssmes=zeros(length(bimes),L);
for i=1:length(bimes)
    ssmes(i,:)=csk(bimes(i,1)+1,:);
end
ssmes=ssmes';
ssmes=reshape(ssmes,1,[]);          % 并串转换

%% 脉冲成型、上变频、信道、下变频、低通滤波

%% 相关解码
N=length(ssmes)/L;                  % 消息个数
en=zeros(1,N);                      % 存储解码
cor=[];                             % 存储互相关函数作图

xxx=[];                             % 存储互相关函数峰值的位置和峰值
for i=1:N
    sym=ssmes(1,1+(i-1)*L:i*L);     % 选取窗口
    corbuf=zeros(1,2*L-1);          % 自相关矩阵缓存
    temp=xcorr(gold,sym);           % 跟原始扩频码做互相关(注意顺序)

    [max_val, linear_idx] = max(temp(:));
    [row, col] = ind2sub(size(temp), linear_idx);
    xxx(i,:)=[row,col,max_val];

    cor=[cor temp];                 % 存储相关矩阵
end 

figure
plot(cor);
title('解码互相关函数图');

encode=[];                          % 根据峰值位置解码
for i=1:N
    if(xxx(i,2)<47)
        encode(i,1)=0;
    elseif(xxx(i,2)<63)
        encode(i,1)=1;
    elseif(xxx(i,2)<79)
        encode(i,1)=2;
    else
        encode(i,1)=3;
    end
end

encode=encode';
encode=de2bi(encode)';
dec=reshape(encode,1,[]);           % 并串转换

%% 误码率
A=find(dec~=mes);
BER=length(A)/length(mes);
disp(['解码误码率：' num2str(BER)])