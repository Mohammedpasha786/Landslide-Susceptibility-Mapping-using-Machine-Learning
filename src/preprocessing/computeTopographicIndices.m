function indices = computeTopographicIndices(dem, pixelSize)
% COMPUTETOPOGRAPHICINDICES  Derive topographic indices from a DEM raster.
%
%   indices = computeTopographicIndices(dem, pixelSize)
%
%   Inputs:
%     dem        - [rows x cols] elevation matrix (metres)
%     pixelSize  - spatial resolution in metres (default: 30)
%
%   Outputs:
%     indices    - struct with fields:
%                    slope, aspect, curvature, plan_curv, profile_curv,
%                    twi, spi, tri, tpi, flow_accum
%
%   References:
%     Zevenbergen & Thorne (1987) — curvature
%     Moore et al. (1991)        — TWI, SPI
%     Riley et al. (1999)        — TRI

    if nargin < 2, pixelSize = 30; end

    dem = double(dem);
    [rows, cols] = size(dem);

    %% ── Finite-difference gradients (3×3 kernel) ────────────────────────
    [dz_dy, dz_dx] = gradient(dem, pixelSize);

    p = dz_dx;   % dz/dx (E-W gradient)
    q = dz_dy;   % dz/dy (N-S gradient)

    %% ── Slope (radians → degrees) ────────────────────────────────────────
    slope_rad = atan(sqrt(p.^2 + q.^2));
    indices.slope = rad2deg(slope_rad);

    %% ── Aspect (degrees, clockwise from North, 0–360) ────────────────────
    aspect_rad = atan2(-q, p);
    aspect_deg = rad2deg(aspect_rad);
    aspect_deg(aspect_deg < 0) = aspect_deg(aspect_deg < 0) + 360;
    indices.aspect = aspect_deg;

    %% ── Curvature (Zevenbergen & Thorne 1987) ────────────────────────────
    % Second derivatives
    [~, d2z_dx2] = gradient(dz_dx, pixelSize);
    [d2z_dy2, ~] = gradient(dz_dy, pixelSize);
    [d2z_dydx, ~] = gradient(dz_dx, pixelSize);

    D = d2z_dx2;
    E = d2z_dy2;
    F = d2z_dydx;

    indices.curvature = -2 * (D + E);  % total curvature

    % Plan curvature (horizontal, perpendicular to slope direction)
    denom = p.^2 + q.^2;
    denom(denom == 0) = eps;
    indices.plan_curv = -(D .* q.^2 - 2*F.*p.*q + E.*p.^2) ./ (denom .* sqrt(1 + denom));

    % Profile curvature (vertical, in slope direction)
    indices.profile_curv = -(D.*p.^2 + 2*F.*p.*q + E.*q.^2) ./ (denom .* sqrt(1 + denom).^3);

    %% ── Flow accumulation (D8 simplified) ────────────────────────────────
    % Approximate: use gradient magnitude as proxy for upslope area
    % For production use, replace with proper D8 or D-infinity algorithm
    flow_accum = zeros(rows, cols);
    for r = 2:rows-1
        for c = 2:cols-1
            kernel = dem(r-1:r+1, c-1:c+1);
            flow_accum(r,c) = sum(kernel(:) > dem(r,c));
        end
    end
    flow_accum = flow_accum * pixelSize^2;   % convert to m²
    flow_accum(flow_accum == 0) = pixelSize^2;
    indices.flow_accum = flow_accum;

    %% ── TWI — Topographic Wetness Index ──────────────────────────────────
    % TWI = ln(As / tan(β)), As = specific catchment area
    slope_tan = tan(slope_rad);
    slope_tan(slope_tan < 0.001) = 0.001;   % avoid divide-by-zero
    As = flow_accum ./ pixelSize;
    indices.twi = log(As ./ slope_tan);

    %% ── SPI — Stream Power Index ─────────────────────────────────────────
    % SPI = As × tan(β)
    indices.spi = As .* slope_tan;

    %% ── TRI — Terrain Ruggedness Index (Riley et al. 1999) ───────────────
    tri = zeros(rows, cols);
    for r = 2:rows-1
        for c = 2:cols-1
            kernel = dem(r-1:r+1, c-1:c+1);
            tri(r,c) = sqrt(sum((kernel(:) - dem(r,c)).^2));
        end
    end
    indices.tri = tri;

    %% ── TPI — Topographic Position Index ────────────────────────────────
    % TPI = elevation − mean of neighbourhood
    kernel_tpi = ones(3,3) / 9;
    mean_neighbour = imfilter(dem, kernel_tpi, 'replicate');
    indices.tpi = dem - mean_neighbour;

    fprintf('  ✓ Topographic indices computed (slope, aspect, curvature, TWI, SPI, TRI, TPI, flow_accum)\n');
end
