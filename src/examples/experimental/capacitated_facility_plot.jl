using GLMakie
using CSV
using DataFrames

cost_progress_df = CSV.read(joinpath(@__DIR__, "cost_progress.txt"), DataFrames.DataFrame)
cost_progress = cost_progress_df[:, :Costs]

fig = Figure();

ax = fig[1, 1] = Axis(fig,
    ## Title
    title = "Cost Progress (Capacitated Facility Location)",
    titlegap = 8, titlesize = 12,

    ## x axis definition
    xgridcolor = :darkgray, xgridwidth = 1,
    xlabel = "Completed Solution Timestep", xlabelsize = 10,
    xticklabelsize = 6, xticks = LinearTicks(10),

    ## y axis
    ygridcolor = :darkgray, ygridwidth = 1,
    ylabel = "Cost", ylabelsize = 10,
    yticklabelsize = 6, yticks = LinearTicks(10),
)

limits!(ax, 0, 30, 1000, 6000)

frames = 1:length(cost_progress)

data = convert.(Int64, cost_progress)

clients = CSV.read(joinpath(@__DIR__, "client_positions.txt"), DataFrames.DataFrame)
LOCATION_UPPER_BOUND = 1000
demands_df = CSV.read(joinpath(@__DIR__, "demands.txt"), DataFrame)
demands = demands_df[:, :Demands]

ax1 = fig[2, 1] = Axis(fig,
    ## Title
    title = "Client-Facility Assignment",
    titlegap = 8, titlesize = 12,

    ## x axis definition
    xgridcolor = :darkgray, xgridwidth = 1,
    xlabel = "x co-ordinate", xlabelsize = 10,
    xticklabelsize = 6, xticks = LinearTicks(10),

    ## y axis
    ygridcolor = :darkgray, ygridwidth = 1,
    ylabel = "y co-ordinate", ylabelsize = 10,
    yticklabelsize = 6, yticks = LinearTicks(10),
);

limits!(ax1, 0, LOCATION_UPPER_BOUND + 100, 0, LOCATION_UPPER_BOUND + 200);

client_points = Point2f.(clients[:, :x], clients[:, :y])

## Scatter plot
clients_plot = scatter!(ax1, 
    client_points,
    markersize = 0.12 .* (50 .+ demands)
);

## Facility positions
facilities = CSV.read(joinpath(@__DIR__,"facility_positions.txt"), DataFrame)
facility_points = Point2f.(facilities[:, :x], facilities[:, :y])
capacities_df = CSV.read(joinpath(@__DIR__, "capacities.txt"), DataFrame)
capacities = capacities_df[:, :Capacities]
facility_colors = Observable(fill(:white, length(facility_points)))

facilities_plot = scatter!(
    ax1,
    facility_points,
    marker= :rect,
    color = facility_colors,
    markersize = capacities .* 0.035,
    strokecolor = :red,
    strokewidth = 2
)

## Read the changes in assignment
client_facility_assignment = CSV.read(joinpath(@__DIR__, "client_facility_assignment.txt"), DataFrame)

NUMBER_OF_ASSIGNMENTS = nrow(client_facility_assignment)
NUMBER_OF_CLIENTS = 8

x_plot_lines = [Observable([clients[i, :x], 0]) for i in 1:NUMBER_OF_CLIENTS]
y_plot_lines = [Observable([clients[i, :y], 0]) for i in 1:NUMBER_OF_CLIENTS]

facility_open_proress = CSV.read(joinpath(@__DIR__, "facility_opening_progress.txt"), DataFrame)

assignment_plot = nothing
## x axis definition
## Simulate the assignment
for i in 1:NUMBER_OF_CLIENTS
    assignment_plot = lines!(
        ax1,
        x_plot_lines[i],
        y_plot_lines[i],
        color= :gray,
    )
end

## Legend Definition
Legend(fig[2, 2], 
    [clients_plot, facilities_plot, assignment_plot],
    ["client", "facility", "assignment"]
)

frames = 1:NUMBER_OF_ASSIGNMENTS

## Function to animate the change in assignment for a client_idx of index idx based on assignment_row
function animate_client_facility_step!(x_plot_lines, y_plot_lines, clients_df, facilities_df, assignment_row, client_idx)
    ## Get the facility location
    assigned_facility = assignment_row[client_idx]
        
    ## Update the plot lines
    x_plot_lines[client_idx][] = [clients_df[client_idx, :x], facilities_df[assigned_facility, :x]]
    y_plot_lines[client_idx][] = [clients_df[client_idx, :y], facilities_df[assigned_facility, :y]]
end

record(fig, "sample_plot.gif", frames; framerate = 1) do f
    ## Cost progress plot
    lines!(ax, 1:f, data[1:f], color = :blue, linewidth = 2)
    scatter!(ax, f, data[f], color = :gray, markersize = 8)

    row = client_facility_assignment[f, :]

    ## Simulate the assignment
    for i in 1:NUMBER_OF_CLIENTS
        animate_client_facility_step!(x_plot_lines, y_plot_lines, clients, facilities, row, i)
    end

    ## Update facility shade
    facility_row = Vector(facility_open_proress[f, :])
    new_facility_colors = Vector{Symbol}(undef, length(facility_row))
    
    for i in eachindex(facility_row)
        new_facility_colors[i] = facility_row[i] ? :red : :white
    end

    facility_colors[] = new_facility_colors
    # sleep(0.001)
end
