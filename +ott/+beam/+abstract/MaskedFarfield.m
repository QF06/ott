classdef MaskedFarfield < ott.beam.properties.MaskedBeam ...
    & ott.beam.abstract.CastNearfield
% Describes composite beam with a masked far-field.
% Inherits from :class:`CastNearfield` and :class:`ott.beam.properties.Beam`.
%
% Static methods
%   - TopHat        -- Creates a top-hat profile
%   - Annular       -- Creates a annular profile
%
% Properties
%   - masked_beam   -- The masked beam (any ott.beam.Beam)
%   - mask          -- Function defining the mask
%
% All casts inherited from base.

% Copyright 2020 Isaac Lenton
% This file is part of OTT, see LICENSE.md for information about
% using/distributing this file.

  methods (Static)
    function beam = TopHat(angle, masked_beam, varargin)
      % Construct a top-hat beam
      %
      % Usage
      %   beam = MaskedParaxial.TopHat(angle, masked_beam, ...)

      mask = @(tp) tp(1, :) <= angle;
      beam = ott.beam.abstract.MaskedFarfield(mask, masked_beam, varargin{:});
    end

    function beam = Annular(angles, masked_beam, varargin)
      % Construct a paraxial masked annular beam
      %
      % Usage
      %   beam = MaskedParaxial.Annular(angles, masked_beam, ...)

      mask = @(tp) tp(1, :) >= angles(1) & tp(1, :) <= angles(2);
      beam = ott.beam.abstract.MaskedFarfield(mask, masked_beam, varargin{:});
    end
  end

  methods
    function beam = MaskedFarfield(varargin)
      % Construct a masked far-field beam
      %
      % Usage
      %   beam = MaskedFarfield(mask, masked_beam, ...)
      %
      % Parameters
      %   - mask (function_handle) -- Masking function.  Should take a
      %     single argument for the paraxial xy position [x; y].
      %
      %   - masked_beam -- Beam to use for paraxial field calculations.

      beam = beam@ott.beam.properties.MaskedBeam(varargin{:});
    end
  end

  methods (Hidden)
    function E = efarfieldInternal(beam, rtp, varargin)
      % Calculate the internal beam far field and then mask

      if size(rtp, 1) == 2
        rtp = [ones(1, size(rtp, 2)); rtp];
      end

      % Calculate field at locations
      E = beam.masked_beam.efarfield(rtp, varargin{:});

      % Compute mask
      mask = beam.mask(rtp(2:3, :));

      % Zero fields outside mask
      vrtp = E.vrtp;
      vrtp(:, ~mask) = 0.0;
      E = ott.utils.FieldVector(rtp, vrtp, 'spherical');
    end

    function H = hfarfieldInternal(beam, rtp, varargin)
      % Calculate the internal beam far field and then mask

      if size(rtp, 1) == 2
        rtp = [ones(1, size(rtp, 2)); rtp];
      end

      % Calculate field at locations
      H = beam.masked_beam.efarfield(rtp, varargin{:});

      % Compute mask
      mask = beam.mask(rtp(2:3, :));

      % Zero fields outside mask
      vrtp = H.vrtp;
      vrtp(:, ~mask) = 0.0;
      H = ott.utils.FieldVector(rtp, vrtp, 'spherical');
    end
  end
end
