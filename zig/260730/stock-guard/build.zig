const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1. メインモジュール (src/root.zig) の定義
    const stock_guard_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // 2. 実行ファイル (src/main.zig) の定義
    const exe = b.addExecutable(.{
        .name = "stock-guard",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "stock_guard", .module = stock_guard_module },
            },
        }),
    });

    b.installArtifact(exe);

    // 3. `zig build run` コマンドの設定
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the stock guard application");
    run_step.dependOn(&run_cmd.step);

    // 4. テストの設定 (`zig build test`)
    // 4a. src/root.zig のテスト
    const run_mod_tests = b.addRunArtifact(b.addTest(.{
        .root_module = stock_guard_module,
    }));

    // 4b. src/main.zig のテスト
    const run_exe_tests = b.addRunArtifact(b.addTest(.{
        .root_module = exe.root_module,
    }));

    // 4c. お題の統合テスト (tests/reorder_service_test.zig) の読み込み
    const integration_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/reorder_service_test.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "stock_guard", .module = stock_guard_module },
            },
        }),
    });
    const run_integration_tests = b.addRunArtifact(integration_tests);

    // 全てのテストを `test` ステップに登録
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
    test_step.dependOn(&run_integration_tests.step);
}
