% --------------------------------------------------------------------
% 项目地址：https://github.com/LvGitHub-9/SpreadSpectrumCommunication
% 模块名称: M元扩频
% 文件名称：MarySS.m
% 版    本：V1.0
% 说    明：M元扩频的扩频解扩过程实现
% 作    者: 小吕同学
% 修改记录：
%     版本号           日期          作者          说明
%      V1.0          2025-1-2         Lv.          发布
% FindMe: https://space.bilibili.com/10179894?spm_id_from=333.1007.0.0
% --------------------------------------------------------------------
% Copyright 2024 Lv. All Rights Reserved. 
% Distributed under MIT license. 
% See file LICENSE for detail or copy at https://opensource.org/licenses/MIT 

%% M元扩频(M-ary Spread Spectrum,MSS)
close all; clear; clc;

%% 消息生成
bits=60;                            % 消息个数
mes=randi([0,1],1,bits);
mary=2;                             % mary进制信源
p=rem(length(mes),mary);            % bit补齐
if(p~=0)
    mes=[mes zeros(1,mary-p)];
end
rmes=reshape(mes,mary,[])';         % 串并转换
bimes=bi2de(rmes);                  % 4进制，2比特

%% Gold序列生成
initial=[1 0 1 1 0 0];              % 6阶
feedback1=103;
feedback2=147;

% % 检测是否为m序列优选对
% [gold1,gold2]=goldseq(initial,feedback1,feedback2,0);
% clear gold1 gold2

m1 = mseq(initial,feedback1,0);
m2 = mseq(initial,feedback2,0);
L=length(m2);                       % 扩频码长

gold=[];                            % Gold扩频码矩阵
gold(1,:) = 2*(mod(m1+m2,2)) - 1;
gold(2,:) = 2*(mod(m1+circshift(m2,15),2)) - 1;
gold(3,:) = 2*(mod(m1+circshift(m2,30),2)) - 1;
gold(4,:) = 2*(mod(m1+circshift(m2,45),2)) - 1;


%% 扩频码选择
ssmes=zeros(length(bimes),L);
for i=1:length(bimes)
    ssmes(i,:)=gold(bimes(i,1)+1,:);
end
ssmes=ssmes';
ssmes=reshape(ssmes,1,[]);          % 并串转换

%% 脉冲成型、上变频、信道、下变频、低通滤波

%% 相关解码
N=length(ssmes)/L;                  % 消息个数
M=size(gold,1);                     % 扩频码个数
en=zeros(M,N);                      % 存储解码
cor=[];                             % 存储互相关函数作图

for i=1:N
    sym=ssmes(1,1+(i-1)*L:i*L);     % 选取窗口
    corbuf=zeros(M,2*L-1);          % 自相关矩阵缓存
    for j=1:M
        temp=xcorr(sym,gold(j,:));  % 跟M个扩频码做互相关，判断峰值
        if(max(abs(temp))>=40)
            en(j,i)=1;
        end
        corbuf(j,:)=temp;
    end
    cor=[cor corbuf];               % 存储相关矩阵
end

figure                              % 作图相关峰矩阵
hold on                             
for i=1:M
    subplot(4,1,i)
    plot(cor(i,:));
    title(['接收消息与第' num2str(i) '个扩频码互相关结果'])
    axis([1 length(cor) -20 L]);
end

encode=zeros(1,N);                  % 峰值解码
for i=1:N
    for j=1:M
        if(en(j,i)==1)
            encode(1,i)=j-1;
        end
    end
end
encode=encode';
encode=de2bi(encode)';
dec=reshape(encode,1,[]);           % 并串转换

%% 误码率
A=find(dec~=mes);
BER=length(A)/length(mes);
disp(['解码误码率：' num2str(BER)])

