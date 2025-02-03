import React, {
  createContext,
  ReactNode,
  useContext,
  useEffect,
  useRef,
  useState,
} from 'react';
import { dojoConfig } from '@frontend/dojo/dojoConfig';
import { DojoProvider } from '@dojoengine/core';
import { init, ParsedEntity, QueryBuilder, SDK, createDojoStore } from '@dojoengine/sdk';
import { ComponentPlayer, schema, SchemaType } from '@frontend/dojo/models';
import { Entity } from '@dojoengine/torii-client';
import { poseidonHashMany } from "micro-starknet";
import { useAccount } from '@starknet-react/core';
import { AccountInterface, BigNumberish } from 'starknet';
/**
 * Interface defining the shape of the Dojo context.
 */
interface DojoContextType {
  sdk: SDK<SchemaType> | null;
  account: AccountInterface | undefined,
  provider: DojoProvider,
  currentTable: number;
  setCurrentTable: (newTable: number) => void;
}

/**
 * React context for sharing Dojo-related data throughout the application.
 */
export const DojoContext = createContext<DojoContextType | null>(null);
export const useDojoStore = createDojoStore<SchemaType>();

/**
 * Provider component that makes Dojo context available to child components.
 *
 * @param children - Child components that will have access to the Dojo context
 * @throws {Error} If DojoProvider is used more than once in the component tree
 */
export const DojoWrapper = ({children}: {children: ReactNode}) => {
  const currentValue = useContext(DojoContext);
  if (currentValue) {
    throw new Error('DojoProvider can only be used once');
  }

  const {account} = useAccount();

  const dojoProvider = new DojoProvider(dojoConfig.manifest, dojoConfig.rpcUrl);
  const [isInitialized, setIsInitialized] = useState(false);
  const sdkRef = useRef<SDK<SchemaType> | null>(null);
  const { setEntities, updateEntity } = useDojoStore(state => ({
    setEntities: state.setEntities,
    updateEntity: state.updateEntity
  }));

  useEffect(() => {
    const initializeSdk = async () => {
      try {
        if (!isInitialized) {
          const initializedSdk = await init<SchemaType>(
            {
              client: {
                rpcUrl: dojoConfig.rpcUrl,
                toriiUrl: dojoConfig.toriiUrl,
                relayUrl: dojoConfig.relayUrl,
                worldAddress: dojoConfig.manifest.world.address,
              },
              domain: {
                name: 'Dominion',
                revision: '1',
                chainId: 'SN_SEPOLIA',
                version: '1.0.0',
              },
            },
            schema,
          );
          sdkRef.current = initializedSdk;

          // Fetch initial entities
          await initializedSdk.getEntities({
            query: new QueryBuilder<SchemaType>().namespace('dominion', (n) => n).build(),
            callback: (resp) => {
              if (resp.error) {
                console.error('Error fetching entities:', resp.error);
                return;
              }
              if (resp.data) {
                setEntities(resp.data as ParsedEntity<SchemaType>[]);
              }
            },
          });

          // Set up subscription
          const subscription = await initializedSdk.subscribeEntityQuery({
            query: new QueryBuilder<SchemaType>()
              .namespace('dominion', (n) => n.entities)
              .build(),
            callback: ({ error, data }) => {
              if (error) {
                console.error('Error in subscription:', error);
                return;
              }
              if (data && (data[0] as ParsedEntity<SchemaType>).entityId !== '0x0') {
                console.log('Entity update received:', data[0]);
                updateEntity(data[0] as ParsedEntity<SchemaType>);
                console.log('Store updated with new entity');
              }
            },
            options: {
              logging: true,
            },
          });

          setIsInitialized(true);

          // Return cleanup function
          return () => {
            console.log('Cleaning up subscriptions');
            subscription.cancel();
          };
        }
      } catch (error) {
        console.error('Failed to initialize SDK:', error);
      }
    };
    initializeSdk()
      .then(_ => console.log("SDK Initialized"),
        e => console.error(e));
  }, [setEntities, updateEntity]); // Empty dependency array

  return (
    <DojoContext.Provider value={{
      sdk: sdkRef.current,
      provider: dojoProvider,
      account: account,
      currentTable: 0,
      // eslint-disable-next-line @typescript-eslint/no-empty-function
      setCurrentTable: (newTable: number) => {
      }
    }}>
      {children}
    </DojoContext.Provider>
  );
};

/**
 * Custom hook to access the Dojo context and account information.
 * Must be used within a DojoProvider component.
 *
 * @returns An object containing:
 *   - setup: The Dojo setup configuration
 *   - account: The current account information
 * @throws {Error} If used outside a DojoProvider context
 */
export function useDojo() {
  const context = useContext(DojoContext);

  if (!context) {
    throw new Error('useDojo must be used within a DojoContext');
  }

  context.setCurrentTable = (newTable) => {
    context.currentTable = newTable;
  }

  const { sdk, provider, account, currentTable, setCurrentTable, ...setup } = context;

  return {
    setup,
    provider,
    account,
    sdk,
    currentTable,
    setCurrentTable
  };
}

/**
 * Custom hook to retrieve a specific model for a given entityId within a specified namespace.
 *
 * @param entities - The keys used to fetch the exact model.
 * @param model - The model to retrieve, specified as a string in the format "namespace-modelName".
 * @returns The model structure if found, otherwise undefined.
 */
export function useModel<M extends keyof SchemaType["dominion"] & string>(entities: BigNumberish[], model: M): SchemaType["dominion"][M] | undefined {

  // Select only the specific model data for the given entity key(s) in that model.
  const entityId = getEntityIdFromKeys(entities.map(key => BigInt(key))).toString();
  return useDojoStore((state) => {
    return state.entities[entityId]?.models?.["dominion"]?.[`${model}`] as SchemaType["dominion"][M] | undefined;
  });
}

/**
 * Custom hook to retrieve a specific model for a given entityId within a specified namespace.
 *
 * @returns The model structure if found, otherwise undefined.
 */
export function useModels<M extends keyof SchemaType["dominion"]>(model: M): (SchemaType["dominion"][M] | undefined)[] {
  // Select only the specific model data for the given entityId
  return useDojoStore((state) => {
    return Object.values(state.entities)
      .filter(entity => entity.models?.dominion?.[`${model}`])
      .map(entity => entity.models.dominion?.[`${model}`] as SchemaType["dominion"][M] | undefined)
  });
}

export function useBalanceChips(player: BigNumberish): BigNumberish | undefined {
  return useDojoStore(state => {
      return state.getEntitiesByModel("dominion", "ComponentPlayer")
        .find(entity => entity.models.dominion.ComponentPlayer?.m_owner === player)
        ?.models.dominion.ComponentPlayer?.m_total_chips
    });
}

/**
 * Determines the entity ID from an array of keys. A poseidon hash of the keys is calculated.
 *
 * @param {bigint[]} keys - An array of big integer keys.
 * @returns {Entity} The determined entity ID.
 */
export function getEntityIdFromKeys(keys: bigint[]): Entity {
  // calculate the poseidon hash of the keys
  const poseidon = poseidonHashMany(keys);
  return ('0x' + poseidon.toString(16)) as unknown as Entity;
}
