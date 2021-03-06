classdef CoPeakGen < dagnn.ElementWise
    properties
        Kernal = ones(3, 3, 3, 3, 'double')
        BatchSize = [];
        PeakMasks = [];
        ThresholdFun = @(X)median(X);
        NumPositiveData = [];
    end
    
    methods
        function outputs = forward(obj, inputs, params)
            obj.BatchSize = size(inputs{1});
            if length(obj.BatchSize) == 4
                obj.BatchSize = [obj.BatchSize 1];
            end
            obj.PeakMasks = gpuArray.false(obj.BatchSize);
            obj.NumPositiveData = zeros(1,  obj.BatchSize(end));
            PositiveData = gpuArray.zeros(obj.BatchSize(end), 1, 'single');
            for i = 1:obj.BatchSize(end)
                TempMap = inputs{1}(:,:,:,:,i);
                obj.PeakMasks(:,:,:,:,i) = gpuArray(imregionalmax(gather(TempMap), obj.Kernal)) ...
                    & TempMap >= obj.ThresholdFun(TempMap(:));
                TeampData = TempMap(obj.PeakMasks(:,:,:,:,i));
                obj.NumPositiveData(i) = length(TeampData);
                PositiveData(i) = mean(TeampData);
            end
            outputs = {PositiveData};
            
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
            derInputs{1} = gpuArray.zeros(obj.BatchSize, 'single');
            for i = 1:obj.BatchSize(end)
                TempPeakMasks = obj.PeakMasks(:,:,:,:,i);
                TempDerInputs = derInputs{1}(:,:,:,:,i);
                TempDerInputs(TempPeakMasks) = derOutputs{1}(i) / obj.NumPositiveData(i);
                derInputs{1}(:,:,:,:,i) = TempDerInputs;
            end
            derParams = {};
        end
       

        function obj = CoPeakGen(varargin)
            obj.load(varargin) ;
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 