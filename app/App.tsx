import {
    Appbar, Button, Dialog, Icon, MD3Theme, Portal, ProgressBar, Text, withTheme,
} from "react-native-paper";
import { NativeModules, StyleSheet, View } from "react-native";
import React, { useEffect, useState } from "react";
import * as FileSystem from "expo-file-system";

const styles = StyleSheet.create({
    container: {
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        padding: 16,
    },
    spaced: {
        width: "100%",
        maxWidth: 1000,
        display: "flex",
        alignItems: "center",
        flexDirection: "column",
        gap: 10,
    },
    appButton: {
        borderRadius: 10,
        width: "100%",
    },
    title: {
        fontSize: 20,
        fontWeight: "bold",
    },
});

function getVersionSortNum(item: any): number {
    if (typeof item.currentVersion !== "number") {
        return 0;
    }
    if (item.version > item.currentVersion) {
        return 1;
    }
    return 2;
}

function getVersionDesc(version: number, currentVersion: number | null): string {
    if (typeof currentVersion !== "number") {
        return "未安装";
    }
    if (version > currentVersion) {
        return "有可用更新";
    }
    return "已是最新版";
}

const App: React.ComponentType<{ theme: MD3Theme }> = ({ theme: { colors } }) => {
    const [error, setError] = useState<string>("");
    const [appList, setAppList] = useState<{
        package: string;
        version: number;
        currentVersion: number | null;
        filename: string;
        name: string;
    }[] | null>(null);
    const [loading, setLoading] = useState<boolean>(false);

    const refreshLocal = async (lst?: any[]) => {
        if (!lst && !appList) return;
        let res = (lst || appList || []) as any[];
        res = await Promise.all(res.map(async (i) => {
            const cv = await NativeModules.LadderAssistAppList.getVersion(i.package);
            return {
                ...i,
                currentVersion: cv < 0 ? null : cv,
            };
        }));
        setAppList(res.sort((a, b) => getVersionSortNum(a) - getVersionSortNum(b)));
    };

    const refresh = async () => {
        setError("");
        const appsRes = await fetch("https://ladder-assist.leoliang.com");
        const apps = await appsRes.json();
        if (apps.version !== 1) {
            setError(`后端版本号不支持：${apps.version}`);
            return;
        }
        if (!Array.isArray(apps.apps)) {
            setError("apps 不是数组。");
            return;
        }
        refreshLocal(apps.apps);
    };

    const download = async (filename: string) => {
        setLoading(true);
        const apkFilename = `ladder-assist-${filename}`;
        const apkPath = FileSystem.cacheDirectory + apkFilename;

        FileSystem.deleteAsync(apkPath, { idempotent: true });
        const res = await FileSystem.downloadAsync(
            `https://ladder-assist.leoliang.com/apk/${filename}`,
            apkPath,
        );
        setLoading(false);
        if (res) {
            NativeModules.LadderAssistApkInstaller.installApp(apkFilename);
        }
    };

    useEffect(() => {
        refresh();
        const a = setInterval(refreshLocal, 3000);
        const b = setInterval(refresh, 60000);
        return () => {
            clearInterval(a);
            clearInterval(b);
        };
    }, []);

    return (
        <View style={{ height: "100%", backgroundColor: colors.background }}>
            <Appbar.Header>
                <Appbar.Content title="梯子辅助" />
            </Appbar.Header>
            <View style={{ backgroundColor: colors.background, ...styles.container }}>
                <Portal>
                    <Dialog visible={loading} dismissable={false}>
                        <Dialog.Title>下载中</Dialog.Title>
                        <Dialog.Content>
                            <ProgressBar indeterminate />
                        </Dialog.Content>
                    </Dialog>
                </Portal>
                {error && (
                    <View style={{ backgroundColor: colors.background, ...styles.spaced }}>
                        <Icon size={50} source="alert-octagon" />
                        <Text variant="titleMedium">发生错误</Text>
                        <Text>{error}</Text>
                        <Button
                            style={styles.appButton}
                            mode="contained"
                            icon="restart"
                            onPress={refresh}
                        >
                            重试
                        </Button>
                    </View>
                )}
                <View style={{ backgroundColor: colors.background, ...styles.spaced }}>
                    {appList ? appList.map((item) => (
                        <Button
                            key={item.package}
                            style={styles.appButton}
                            mode={
                                item.currentVersion === null || item.currentVersion < item.version
                                    ? "contained"
                                    : "outlined"
                            }
                            onPress={() => download(item.filename)}
                        >
                            {item.name}
                            ：
                            {getVersionDesc(item.version, item.currentVersion)}
                        </Button>
                    )) : null}
                </View>
            </View>
        </View>
    );
};
export default withTheme(App);
