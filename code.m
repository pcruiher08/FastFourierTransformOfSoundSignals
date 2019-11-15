classdef tercerProyecto < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        RecordButton                    matlab.ui.control.Button
        DisplayButton                   matlab.ui.control.Button
        UIAxes                          matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        TransformButton                 matlab.ui.control.Button
        DryingMachineLampLabel          matlab.ui.control.Label
        DryingMachineLamp               matlab.ui.control.Lamp
        WaterFlowingLampLabel           matlab.ui.control.Label
        WaterFlowingLamp                matlab.ui.control.Lamp
        PhoneRingtoneLampLabel          matlab.ui.control.Label
        PhoneRingtoneLamp               matlab.ui.control.Lamp
        CarClaxonLampLabel              matlab.ui.control.Label
        CarClaxonLamp                   matlab.ui.control.Lamp
        ComputerBootingLampLabel        matlab.ui.control.Label
        ComputerBootingLamp             matlab.ui.control.Lamp
        CompareButton                   matlab.ui.control.Button
        BrowseButton                    matlab.ui.control.Button
        MaximumMagnitudeEditFieldLabel  matlab.ui.control.Label
        MaximumMagnitudeEditField       matlab.ui.control.EditField
        SelectFileButton                matlab.ui.control.Button
        FeedbackTextArea                matlab.ui.control.TextArea
    end

    properties (Access = public)
        
        %PUBLIC VARIABLES
        magnitude;
        %audioObject;
        soundFunction; 
        frequency = 8000;
    end

    methods (Access = private)

        % Button pushed function: RecordButton
        function RecordButtonPushed(app, event)
            %app.DryingMachineLamp.Color = 'white';
            %app.WaterFlowingLamp.Color = 'white';
            %app.PhoneRingtoneLamp.Color = 'white';
            %app.CarClaxonLamp.Color = 'white';
            %app.ComputerBootingLamp.Color = 'white';
            
            %RECORDING ROUNTINE AND SAVING
            audioObject = audiorecorder(8000,8,1);    
            msgbox('Inicia grabación');
            recordblocking(audioObject,1);
            msgbox('Terminó grabación');
            app.frequency = audioObject.SampleRate;
            app.soundFunction = getaudiodata(audioObject);
      
      
            filename = app.FeedbackTextArea.Value{1};
            defaultPath = 'D:\programacion\FastFourierTransformOfSoundSignals\';
            fullPath = strcat(defaultPath,app.FeedbackTextArea.Value{1});
            fullPath = strcat(fullPath,'.wav');
            audiowrite(fullPath,app.soundFunction,app.frequency);
       
            
            %assignin('base','audioObject',audioObject);
        end

        % Button pushed function: DisplayButton
        function DisplayButtonPushed(app, event)
            %audioObject = evalin('base', 'audioObject');
            %soundFunction = getaudiodata(audioObject);
            %Fs = audioObject.SampleRate;
            
            %DISPLAY PLOT OF SOUND
            Fs = app.frequency;
            soundFunction = app.soundFunction;
            n=1;
            t=0:Fs*n-1;
            t=t/Fs;
            plot(app.UIAxes,t,soundFunction);
            sound(soundFunction,Fs);
        end

        % Button pushed function: TransformButton
        function TransformButtonPushed(app, event)
            %audioObject = evalin('base', 'audioObject');
            %soundFunction = getaudiodata(audioObject.app);
            
            %FFT ALGORITHM
            fm = app.frequency;
            Np=8192;                             % Número de puntos de la DFT
            L=length(app.soundFunction);             % Longitud de la señal
            Tm=(1/fm);                           % Tiempo de muestreo
            Mp=ceil(Np/2);                       % Mitad de puntos de la FFT
            wd=0:2*pi/Np:2*pi*(Np-1)/Np;         % Vector de Frec. discreta
            wdo=zeros(1,Np);                     % Vector de Frec. disc. organizadas
            wc=zeros(1,Np);                      % Vector de Frec. cont. en rad/seg
            fc=zeros(1,Np);                      % Vector de Frec. cont. en Hz
            z=abs(fft(app.soundFunction,Np));        % Magnitud de FFT de la señal
            zo=zeros(1,Np);                      % Vector para reorganizar la FFT
            t=0:Tm:Tm*(L-1);                     % Vector de tiempo
            % Reorganización de frecuencias
            wdo(Np-Mp+1:end)=wd(1:Mp);
            wdo(1:Np-Mp)=wd(Mp+1:end)-2*pi;
            % Frecuencia continua en Hz
            wc=wdo/Tm;
            fc=wc/(2*pi);
            % Reorganización de la FFT
            zo(Np-Mp+1:end)=z(1:Mp);
            zo(1:Np-Mp)=z(Mp+1:end);
            M=zo;
            freq=fc;
            %figure;
            plot(app.UIAxes2,freq,mag2db(M));
            %plot(freq,mag2db(M));
            %title('Magnitud de la transformada de Fourier');   
            %xlabel('Frecuencia (Hz)');
            %ylabel('Amplitude (dB)');
            %disp("maxima frecuencia: " + max(M));
            %disp("maxima magnitud en dB" + max(mag2db(M)))
            app.magnitude = M;
        end

        % Button pushed function: CompareButton
        function CompareButtonPushed(app, event)
            magnitudeInDb = int16(mag2db(max(app.magnitude)));
            %MAPPING OF MAGNITUDES
            maxMagnitudeWashingMachine = 25;
            maxMagnitudeFlowingWater = 30;
            maxMagnitudeComputerStarting = 33;
            maxMagnitudeCarClaxon = 44;
            maxMagnitudeTelephoneRingtone = 28;
            app.MaximumMagnitudeEditField.Value = int2str(magnitudeInDb);
            %SELECTION OF ALERT 3 PERCENT OF VARIATION
            app.DryingMachineLamp.Color = 'green';
            app.WaterFlowingLamp.Color = 'green';
            app.PhoneRingtoneLamp.Color = 'green';
            app.CarClaxonLamp.Color = 'green';
            app.ComputerBootingLamp.Color = 'green';
            if (magnitudeInDb <= ceil(maxMagnitudeWashingMachine*1.03) && magnitudeInDb >= floor(maxMagnitudeWashingMachine * 0.97))
                app.DryingMachineLamp.Color = 'red';
            elseif (magnitudeInDb <= ceil(maxMagnitudeFlowingWater*1.03) && magnitudeInDb >= floor(maxMagnitudeFlowingWater * 0.97))
                app.WaterFlowingLamp.Color = 'red';
            elseif (magnitudeInDb <= ceil(maxMagnitudeComputerStarting*1.03) && magnitudeInDb >= floor(maxMagnitudeComputerStarting * 0.97))
                app.ComputerBootingLamp.Color = 'red';
            elseif (magnitudeInDb <= ceil(maxMagnitudeCarClaxon*1.03) && magnitudeInDb >= floor(maxMagnitudeCarClaxon * 0.97))
                app.CarClaxonLamp.Color = 'red';
            elseif (magnitudeInDb <= ceil(maxMagnitudeTelephoneRingtone*1.03) && magnitudeInDb >= maxMagnitudeTelephoneRingtone * 0.97)
                app.PhoneRingtoneLamp.Color = 'red';
            end
        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            
            [file path] = uigetfile({'D:\programacion\FastFourierTransformOfSoundSignals\*.wav'},'File selection');
            fullpath = strcat(path,file);
            app.FeedbackTextArea.Value = fullpath;
            %app.EditField.set(fullpath);
            
          %  [y, Fs] = audioread();
           %  app.soundFunction = y; 
            % app.frequency = Fs;
        end

        % Button pushed function: SelectFileButton
        function SelectFileButtonPushed(app, event)
            %FILE BROWSER SELECTION
            [y,Fs] = audioread(app.FeedbackTextArea.Value{1});
            app.soundFunction = y;
            app.frequency = Fs;
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create RecordButton
            app.RecordButton = uibutton(app.UIFigure, 'push');
            app.RecordButton.ButtonPushedFcn = createCallbackFcn(app, @RecordButtonPushed, true);
            app.RecordButton.Position = [69 360 100 22];
            app.RecordButton.Text = 'Record';

            % Create DisplayButton
            app.DisplayButton = uibutton(app.UIFigure, 'push');
            app.DisplayButton.ButtonPushedFcn = createCallbackFcn(app, @DisplayButtonPushed, true);
            app.DisplayButton.Position = [69 328 100 22];
            app.DisplayButton.Text = 'Display';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Sound Spectrum')
            xlabel(app.UIAxes, 'Time (s)')
            ylabel(app.UIAxes, 'Amplitude (Db)')
            app.UIAxes.PlotBoxAspectRatio = [1 0.511111111111111 0.511111111111111];
            app.UIAxes.Position = [259 234 300 185];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Sound Spectrum in the Frequency Domain')
            xlabel(app.UIAxes2, 'Frequency (Hz)')
            ylabel(app.UIAxes2, 'Amplitude (Db)')
            app.UIAxes2.PlotBoxAspectRatio = [1 0.515923566878981 0.515923566878981];
            app.UIAxes2.Position = [259 28 300 185];

            % Create TransformButton
            app.TransformButton = uibutton(app.UIFigure, 'push');
            app.TransformButton.ButtonPushedFcn = createCallbackFcn(app, @TransformButtonPushed, true);
            app.TransformButton.Position = [69 297 100 22];
            app.TransformButton.Text = 'Transform';

            % Create DryingMachineLampLabel
            app.DryingMachineLampLabel = uilabel(app.UIFigure);
            app.DryingMachineLampLabel.HorizontalAlignment = 'right';
            app.DryingMachineLampLabel.Position = [69 174 89 22];
            app.DryingMachineLampLabel.Text = 'Drying Machine';

            % Create DryingMachineLamp
            app.DryingMachineLamp = uilamp(app.UIFigure);
            app.DryingMachineLamp.Position = [173 174 20 20];

            % Create WaterFlowingLampLabel
            app.WaterFlowingLampLabel = uilabel(app.UIFigure);
            app.WaterFlowingLampLabel.HorizontalAlignment = 'right';
            app.WaterFlowingLampLabel.Position = [76 140 82 22];
            app.WaterFlowingLampLabel.Text = 'Water Flowing';

            % Create WaterFlowingLamp
            app.WaterFlowingLamp = uilamp(app.UIFigure);
            app.WaterFlowingLamp.Position = [173 140 20 20];

            % Create PhoneRingtoneLampLabel
            app.PhoneRingtoneLampLabel = uilabel(app.UIFigure);
            app.PhoneRingtoneLampLabel.HorizontalAlignment = 'right';
            app.PhoneRingtoneLampLabel.Position = [67 104 91 22];
            app.PhoneRingtoneLampLabel.Text = 'Phone Ringtone';

            % Create PhoneRingtoneLamp
            app.PhoneRingtoneLamp = uilamp(app.UIFigure);
            app.PhoneRingtoneLamp.Position = [173 104 20 20];

            % Create CarClaxonLampLabel
            app.CarClaxonLampLabel = uilabel(app.UIFigure);
            app.CarClaxonLampLabel.HorizontalAlignment = 'right';
            app.CarClaxonLampLabel.Position = [92 69 66 22];
            app.CarClaxonLampLabel.Text = 'Car Claxon';

            % Create CarClaxonLamp
            app.CarClaxonLamp = uilamp(app.UIFigure);
            app.CarClaxonLamp.Position = [173 69 20 20];

            % Create ComputerBootingLampLabel
            app.ComputerBootingLampLabel = uilabel(app.UIFigure);
            app.ComputerBootingLampLabel.HorizontalAlignment = 'right';
            app.ComputerBootingLampLabel.Position = [56 36 102 22];
            app.ComputerBootingLampLabel.Text = 'Computer Booting';

            % Create ComputerBootingLamp
            app.ComputerBootingLamp = uilamp(app.UIFigure);
            app.ComputerBootingLamp.Position = [173 36 20 20];

            % Create CompareButton
            app.CompareButton = uibutton(app.UIFigure, 'push');
            app.CompareButton.ButtonPushedFcn = createCallbackFcn(app, @CompareButtonPushed, true);
            app.CompareButton.Position = [69 262 100 22];
            app.CompareButton.Text = 'Compare';

            % Create BrowseButton
            app.BrowseButton = uibutton(app.UIFigure, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [69 432 100 22];
            app.BrowseButton.Text = 'Browse';

            % Create MaximumMagnitudeEditFieldLabel
            app.MaximumMagnitudeEditFieldLabel = uilabel(app.UIFigure);
            app.MaximumMagnitudeEditFieldLabel.HorizontalAlignment = 'right';
            app.MaximumMagnitudeEditFieldLabel.Position = [23 7 117 22];
            app.MaximumMagnitudeEditFieldLabel.Text = 'Maximum Magnitude';

            % Create MaximumMagnitudeEditField
            app.MaximumMagnitudeEditField = uieditfield(app.UIFigure, 'text');
            app.MaximumMagnitudeEditField.Position = [155 7 100 22];

            % Create SelectFileButton
            app.SelectFileButton = uibutton(app.UIFigure, 'push');
            app.SelectFileButton.ButtonPushedFcn = createCallbackFcn(app, @SelectFileButtonPushed, true);
            app.SelectFileButton.Position = [69 397 100 22];
            app.SelectFileButton.Text = 'Select File';

            % Create FeedbackTextArea
            app.FeedbackTextArea = uitextarea(app.UIFigure);
            app.FeedbackTextArea.Position = [192 432 367 22];
        end
    end

    methods (Access = public)

        % Construct app
        function app = tercerProyecto

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end