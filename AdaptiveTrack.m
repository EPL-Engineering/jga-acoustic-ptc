classdef AdaptiveTrack
   % ADAPTIVETRACK -- encapsulates properties and methods for executing an
   % adaptive tracking procedure.
   % $Rev: 45 $
   % $Date: 2022-12-21 17:12:11 -0500 (Wed, 21 Dec 2022) $
   
   properties (SetAccess = public)     
      NumIntervals = 2;
      NumDown = 2;
      NumUp = 1;
      NumReversalsToAcquire = 6;
      NumReversalsToAverage = 4;
      InitialValue = NaN;
      MinValue = -Inf;
      MaxValue = +Inf;
      VariableName = '';
      StepSize = 1; % step size in the "up" direction, i.e. in response to being wrong
   end

   properties (SetAccess = private, GetAccess = public)
      Operation = 'add';
      Metric = 'mean';
      CurrentValue;
      Threshold;
      ThresholdSD;
      Status;
   end
   
   properties (SetAccess = private)
      isDiscrete = false;
      lastCorrect = false;
      numConsecutive = 0;
      lastDirection = 0;
      reversals = [];
      history = [];
      valueIndex = [];
      values = [];
      secondaryName = '';
      itemValues = []; % for discrete tracks
      numTestEdgeIncorrect = 4;
      numTestEdgeCorrect = 6;
   end
   
   methods
      function obj = AdaptiveTrack()
      end
      
      %--------------------------------------------------------------------
      function obj = Initialize(obj, variableName, initialValue, minValue, maxValue)
         obj.VariableName = variableName;
         obj.InitialValue = initialValue;
         obj.MinValue = minValue;
         obj.MaxValue = maxValue;
         obj.isDiscrete = false;
         
         obj = obj.Reset();
      end
      
      %--------------------------------------------------------------------
      function obj = InitializeDiscrete(obj, variableName, initialIndex, values)
         obj.VariableName = variableName;
         obj.InitialValue = initialIndex;
         obj.values = values;
         obj.MinValue = min(values);
         obj.MaxValue = max(values);
         obj.isDiscrete = true;
         obj.secondaryName = '';
         obj.itemValues = [];
         
         obj = obj.Reset();
      end
      
      %--------------------------------------------------------------------
      function obj = SetItemValues(obj, variableName, itemValues)
         obj.secondaryName = variableName;
         obj.itemValues = itemValues;
      end
      
      %--------------------------------------------------------------------
      function obj = Reset(obj)
         obj.numConsecutive = 0;
         obj.lastDirection = 0;
         obj.reversals = [];
         if obj.isDiscrete
            obj.valueIndex = obj.InitialValue;
            obj.CurrentValue = obj.values(obj.valueIndex);
         else
            obj.CurrentValue = obj.InitialValue;
         end
         
         obj.history = struct('value', [], 'correctInterval', [], 'response', [], 'reactionTime', [], 'isCorrect', [], 'isReversal', []);
         obj.Status = 'active';
         
      end

      %--------------------------------------------------------------------
      function obj = Update(obj, actualResponse, correctResponse, reactionTime)
         isCorrect = actualResponse == correctResponse;

         obj.history(end+1) = struct(...
            'value', obj.CurrentValue, ...
            'correctInterval', correctResponse, ...
            'response', actualResponse, ...
            'reactionTime', reactionTime, ...
            'isCorrect', isCorrect, ...
            'isReversal', false);
         
         if isCorrect ~= obj.lastCorrect
            obj.numConsecutive = 0;
         end

         if isCorrect
            obj.numConsecutive = obj.numConsecutive + 1;

            downCriterion = obj.NumDown;
            if obj.isDiscrete && ((obj.valueIndex == 1 && obj.StepSize(1) > 0) || (obj.valueIndex == length(obj.values) && obj.StepSize(1) < 0))
               downCriterion = obj.numTestEdgeCorrect;
            end

            if obj.numConsecutive == downCriterion
               obj.numConsecutive = 0;

               if obj.lastDirection == 1
                  obj.history(end).isReversal = true;
                  obj.reversals(end+1) = obj.CurrentValue;
               end
               obj = obj.UpdateValue('down', length(obj.reversals));              
            end

         else % INCORRECT
            obj.numConsecutive = obj.numConsecutive + 1;
            
            upCriterion = obj.NumUp;
            if obj.isDiscrete && ((obj.valueIndex == 1 && obj.StepSize(1) < 0) || (obj.valueIndex == length(obj.values) && obj.StepSize(1) > 0))
               upCriterion = obj.numTestEdgeIncorrect;
%             elseif obj.CurrentValue == obj.MinValue || obj.CurrentValue == obj.MaxValue
%                upCriterion = obj.numTestEdgeIncorrect;
            end
            
            if obj.numConsecutive == upCriterion
               obj.numConsecutive = 0;

               if obj.lastDirection == -1
                  obj.history(end).isReversal = true;
                  obj.reversals(end+1) = obj.CurrentValue;
               end

               obj = obj.UpdateValue('up', length(obj.reversals));

            end
         end

         obj.lastCorrect = isCorrect;

         if length(obj.reversals) == obj.NumReversalsToAcquire
            reversalsToAverage = obj.GetReversalsToAverage();
            obj.Threshold = mean(reversalsToAverage);
            obj.ThresholdSD = std(reversalsToAverage);
            obj.Status = 'finished';
         elseif obj.isDiscrete
            if obj.valueIndex < 1 || obj.valueIndex > length(obj.values)
               obj.Status = 'value out of range';
            else
               obj.CurrentValue = obj.values(obj.valueIndex);
            end
         elseif obj.CurrentValue < obj.MinValue || obj.CurrentValue > obj.MaxValue
            obj.Status = 'value out of range';
         end
      end

      %--------------------------------------------------------------------
      function reversals = GetReversalsToAverage(obj)
         reversals = obj.reversals((obj.NumReversalsToAcquire - obj.NumReversalsToAverage + 1):end);
      end

      %--------------------------------------------------------------------
      function obj = SaveProperties(obj, matPath)
         adapt = struct(...
            'NumIntervals', obj.NumIntervals, ...
            'NumDown', obj.NumDown, ...
            'NumUp', obj.NumUp, ...
            'NumReversalsToAcquire', obj.NumReversalsToAcquire, ...
            'NumReversalsToAverage', obj.NumReversalsToAverage, ...
            'InitialValue', obj.InitialValue, ...
            'MinValue', obj.MinValue, ...
            'MaxValue', obj.MaxValue, ...
            'VariableName', obj.VariableName, ...
            'StepSize', obj.StepSize, ...
            'Operation', obj.Operation, ...
            'Metric', obj.Metric);

         save(matPath, 'adapt', '-append');
      end

      %--------------------------------------------------------------------
      function obj = SaveHistory(obj, matPath)
         history = obj.history; %#ok<PROPLC> 
         save(matPath, 'history', '-append');
      end

      %--------------------------------------------------------------------
      function obj = PlotTrack(obj, hax)
         correctColor = [0 0.5 0];
         wrongColor = [0.5 0 0];
         
         if isempty(obj.history(1).value)
            cla(hax, 'reset');
         end
         
         if obj.isDiscrete && ~isempty(obj.itemValues)
            yyaxis(hax, 'left');
         end
         
         cla(hax);
         hold(hax, 'on');

         isCorrect = [obj.history.isCorrect];
         isReversal = [obj.history.isReversal];
         value = [obj.history.value];

         ifilt = find(isCorrect & ~isReversal);
         if ~isempty(ifilt)
            plot(hax, ifilt, value(ifilt), 'o', 'Color', correctColor, 'LineWidth', 1.25);
         end

         ifilt = find(isCorrect & isReversal);
         if ~isempty(ifilt)
            plot(hax, ifilt, value(ifilt), 'o', 'Color', correctColor, 'MarkerFaceColor', correctColor, 'LineWidth', 1);
         end

         ifilt = find(~isCorrect & ~isReversal);
         if ~isempty(ifilt)
            plot(hax, ifilt, value(ifilt), 'o', 'Color', wrongColor, 'LineWidth', 1.25);
         end

         ifilt = find(~isCorrect & isReversal);
         if ~isempty(ifilt)
            plot(hax, ifilt, value(ifilt), 'o', 'Color', wrongColor, 'MarkerFaceColor', wrongColor, 'LineWidth', 1);
         end

         set(hax, 'XLim', [0 ceil(length(obj.history)/10) * 10 + 1]);
         set(hax, 'YLim', [obj.MinValue obj.MaxValue]);

         grid(hax, 'on');
         
         xlabel(hax, 'Trial');
         ylabel(hax, obj.VariableName);
         
         if obj.isDiscrete && ~isempty(obj.itemValues)
            itick = get(hax, 'YTick');
            itick = itick(ismember(itick, obj.values));
            set(hax, 'YTick', itick);
            
            yyaxis(hax, 'right');
            set(hax, 'YLim', [obj.MinValue obj.MaxValue]);
            
            itick = get(hax, 'YTick');
            itick = itick(ismember(itick, obj.values));
            set(hax, 'YTick', itick);
            
            ytl = cell(length(itick), 1);
            for k = 1:length(itick)
               ytl{k} = num2str(obj.itemValues(find(obj.values == itick(k))));
            end
            set(hax, 'YTickLabel', ytl);
            
            ylabel(hax, obj.secondaryName);
         end

      end

      %--------------------------------------------------------------------
      function obj = SetOperation(obj, op)
         validOps = {'add', 'multiply'};
         if ~ismember(lower(op), validOps)
            error('Invalid adaptation operation');
         end
         obj.Operation = lower(op);
      end
      
      %--------------------------------------------------------------------
      function obj = SetMetric(obj, metric)
         validMetrics = {'mean'};
         if ~ismember(lower(metric), validMetrics)
            error('Invalid threshold metric');
         end
         obj.Metric = lower(metric);
      end
   end

   %--------------------------------------------------------------------------
   % PRIVATE METHODS
   %--------------------------------------------------------------------------
   methods (Access = private)
      function obj = UpdateValue(obj, direction, nrev)
         delta = obj.StepSize(min(nrev+1, length(obj.StepSize)));
         switch obj.Operation
            case 'add'
               if isequal(direction, 'down'), delta = -delta; end
               if obj.isDiscrete
                  obj.valueIndex = obj.valueIndex + delta;
               else
                  obj.CurrentValue = obj.CurrentValue + delta;
               end
            case 'multiply'
               if isequal(direction, 'down'), delta = 1 / delta; end
               obj.CurrentValue = obj.CurrentValue * delta;
         end

         if isequal(direction, 'down')
            obj.lastDirection = -1;
         else
            obj.lastDirection = 1;
         end
      end
   end
   
end
